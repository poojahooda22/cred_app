import 'dart:math';
import 'dart:typed_data';

/// PIC/FLIP fluid simulation on a MAC (Marker-And-Cell) staggered grid.
///
/// Faithful port of the production WebGL2 implementation. Uses Gauss-Seidel
/// pressure projection for incompressibility, spatial-hash particle
/// separation, and bilinear P2G / G2P velocity transfer with air-cell
/// validity masking.
class FlipFluid {
  static const int fluidCell = 0;
  static const int airCell = 1;
  static const int solidCell = 2;

  // ── Grid ─────────────────────────────────────────────────────────
  final int fNumX, fNumY, fNumCells;
  final double h, fInvSpacing;
  final double simWidth, simHeight;
  final double density;

  late final Float64List u, v;
  late final Float64List du, dv; // weight accumulators for P2G
  late final Float64List prevU, prevV;
  late final Float64List p; // pressure
  late final Float64List s; // solid mask (0=solid, 1=open)
  late final Int32List cellType;
  late final Float64List particleDensity;
  double particleRestDensity = 0.0;

  // ── Particles ────────────────────────────────────────────────────
  int numParticles = 0;
  final int maxParticles;
  late final Float64List particlePos;
  late final Float64List particleVel;
  final double particleRadius;
  final double particleGap;

  // ── Spatial hash ─────────────────────────────────────────────────
  late final int pNumX, pNumY, pNumCells;
  late final double pInvSpacing;
  late final Int32List numCellParticles;
  late final Int32List firstCellParticle;
  late final Int32List cellParticleIds;

  // ── State ────────────────────────────────────────────────────────
  double waveTime = 0.0;
  int frameCount = 0;

  FlipFluid({
    required this.density,
    required double width,
    required double height,
    required double spacing,
    required this.particleRadius,
    required this.particleGap,
    required this.maxParticles,
  })  : simWidth = width,
        simHeight = height,
        fNumX = (width / spacing).floor() + 1,
        fNumY = (height / spacing).floor() + 1,
        h = max(width / ((width / spacing).floor() + 1),
            height / ((height / spacing).floor() + 1)),
        fInvSpacing = 1.0 /
            max(width / ((width / spacing).floor() + 1),
                height / ((height / spacing).floor() + 1)),
        fNumCells = ((width / spacing).floor() + 1) *
            ((height / spacing).floor() + 1) {
    u = Float64List(fNumCells);
    v = Float64List(fNumCells);
    du = Float64List(fNumCells);
    dv = Float64List(fNumCells);
    prevU = Float64List(fNumCells);
    prevV = Float64List(fNumCells);
    p = Float64List(fNumCells);
    s = Float64List(fNumCells);
    cellType = Int32List(fNumCells);
    particleDensity = Float64List(fNumCells);

    particlePos = Float64List(2 * maxParticles);
    particleVel = Float64List(2 * maxParticles);

    // Spatial hash cell size — negative gap is fine as long as the total stays positive
    pInvSpacing = 1.0 / max(particleRadius, 2.2 * particleRadius + particleGap);
    pNumX = (width * pInvSpacing).floor() + 1;
    pNumY = (height * pInvSpacing).floor() + 1;
    pNumCells = pNumX * pNumY;
    numCellParticles = Int32List(pNumCells);
    firstCellParticle = Int32List(pNumCells + 1);
    cellParticleIds = Int32List(maxParticles);

    // Mark boundary cells solid
    final n = fNumY;
    for (int i = 0; i < fNumX; i++) {
      for (int j = 0; j < fNumY; j++) {
        s[i * n + j] =
            (i == 0 || i == fNumX - 1 || j == 0 || j == fNumY - 1) ? 0.0 : 1.0;
      }
    }
  }

  // ── Spawn hex-packed particles ──────────────────────────────────
  void spawnHexPacked({
    double relWaterWidth = 1.0,
    double relWaterHeight = 0.42,
    double xOffsetFraction = 0.0, // 0.0 = left edge, 0.5 = right half
  }) {
    final minDistSpawn = 2.0 * particleRadius + particleGap;
    final dx = minDistSpawn;
    final dy = sqrt(3.0) / 2.0 * dx;
    final wallPad = particleRadius + particleGap * 0.5;
    final jitter = 0.2 * particleRadius;
    final rng = Random(42);

    final spawnWidth = relWaterWidth * simWidth;
    final xStart = h + wallPad + (simWidth - 2.0 * h - 2.0 * wallPad) * xOffsetFraction;
    final numX = ((spawnWidth - 2.0 * h - 2.0 * wallPad) / dx).round();
    final numY =
        ((relWaterHeight * simHeight - 2.0 * h - 2.0 * wallPad) / dy).round();

    int p = 0;
    for (int i = 0; i < numX; i++) {
      for (int j = 0; j < numY; j++) {
        if (p ~/ 2 >= maxParticles) break;
        final px = xStart +
            dx * i +
            (j % 2 == 0 ? 0.0 : 0.5 * dx) +
            (rng.nextDouble() - 0.5) * jitter;
        // Clamp to right wall
        if (px > (fNumX - 1) * h - wallPad) continue;
        particlePos[p++] = px;
        particlePos[p++] =
            h + wallPad + dy * j + (rng.nextDouble() - 0.5) * jitter;
      }
    }
    numParticles = p ~/ 2;

    // Compute rest density from initial packing
    _updateParticleDensity();
    double maxDens = 0.0;
    for (int ci = 0; ci < fNumX; ci++) {
      for (int cj = 0; cj < fNumY; cj++) {
        if (s[ci * fNumY + cj] != 0.0) {
          final d = particleDensity[ci * fNumY + cj];
          if (d > maxDens) maxDens = d;
        }
      }
    }
    particleRestDensity = maxDens > 0 ? maxDens * 0.95 : 0.0;
  }

  // ── Main simulation step ────────────────────────────────────────
  void simulate({
    required double dt,
    required double gravity,
    required double flipRatio,
    required int numPressureIters,
    required int numParticleIters,
    required double overRelaxation,
    double obstacleX = -100,
    double obstacleY = -100,
    double obstacleRadius = 0.15,
    double obstacleVelX = 0.0,
    double obstacleVelY = 0.0,
    double tiltForceX = 0.0,
    double tiltForceY = 0.0,
  }) {
    integrateParticles(dt, gravity, tiltForceX, tiltForceY);
    pushParticlesApart(numParticleIters);
    handleParticleCollisions(
        obstacleX, obstacleY, obstacleRadius, obstacleVelX, obstacleVelY);
    transferVelocities(true, flipRatio);
    _updateParticleDensity();
    solveIncompressibility(numPressureIters, dt, overRelaxation);
    transferVelocities(false, flipRatio);
    dampVelocities(0.005);
    dampSettledParticles(0.35, 0.08);
    clampVelocities(8.0);

    frameCount++;
  }

  // ── 1. Integrate (forces + advection ONLY — no damping, no walls) ──
  void integrateParticles(
      double dt, double gravity, double tiltForceX, double tiltForceY) {
    for (int i = 0; i < numParticles; i++) {
      particleVel[2 * i] += dt * tiltForceX;
      particleVel[2 * i + 1] += dt * (gravity + tiltForceY);
      particlePos[2 * i] += particleVel[2 * i] * dt;
      particlePos[2 * i + 1] += particleVel[2 * i + 1] * dt;
    }
  }

  // ── 2. Push particles apart + wall separation ───────────────────
  void pushParticlesApart(int numIters) {
    final minDist = 2.0 * particleRadius + particleGap;
    final minDist2 = minDist * minDist;
    final halfDist = minDist * 0.5;
    final wh = h;
    final leftWall = wh;
    final rightWall = (fNumX - 1) * wh;
    final bottomWall = wh;
    final topWall = (fNumY - 1) * wh;

    for (int iter = 0; iter < numIters; iter++) {
      // Rebuild spatial hash
      numCellParticles.fillRange(0, pNumCells, 0);
      for (int i = 0; i < numParticles; i++) {
        final xi =
            (particlePos[2 * i] * pInvSpacing).floor().clamp(0, pNumX - 1);
        final yi = (particlePos[2 * i + 1] * pInvSpacing)
            .floor()
            .clamp(0, pNumY - 1);
        numCellParticles[xi * pNumY + yi]++;
      }
      int first = 0;
      for (int i = 0; i < pNumCells; i++) {
        first += numCellParticles[i];
        firstCellParticle[i] = first;
      }
      firstCellParticle[pNumCells] = first;
      for (int i = 0; i < numParticles; i++) {
        final xi =
            (particlePos[2 * i] * pInvSpacing).floor().clamp(0, pNumX - 1);
        final yi = (particlePos[2 * i + 1] * pInvSpacing)
            .floor()
            .clamp(0, pNumY - 1);
        final cellNr = xi * pNumY + yi;
        firstCellParticle[cellNr]--;
        cellParticleIds[firstCellParticle[cellNr]] = i;
      }

      // Separation pass
      for (int i = 0; i < numParticles; i++) {
        final px = particlePos[2 * i], py = particlePos[2 * i + 1];
        final pxi = (px * pInvSpacing).floor();
        final pyi = (py * pInvSpacing).floor();
        final x0 = max(pxi - 1, 0);
        final y0 = max(pyi - 1, 0);
        final x1 = min(pxi + 1, pNumX - 1);
        final y1 = min(pyi + 1, pNumY - 1);

        for (int xi = x0; xi <= x1; xi++) {
          for (int yi = y0; yi <= y1; yi++) {
            final cellNr = xi * pNumY + yi; // pNumY, NOT fNumY
            final cfirst = firstCellParticle[cellNr];
            final clast = firstCellParticle[cellNr + 1];
            for (int k = cfirst; k < clast; k++) {
              final id = cellParticleIds[k];
              if (id == i) continue;

              double ddx = particlePos[2 * id] - px;
              double ddy = particlePos[2 * id + 1] - py;
              final d2 = ddx * ddx + ddy * ddy;
              if (d2 > minDist2 || d2 == 0.0) continue;
              final d = sqrt(d2);
              final s = 0.5 * (minDist - d) / d;
              ddx *= s;
              ddy *= s;
              particlePos[2 * i] -= ddx;
              particlePos[2 * i + 1] -= ddy;
              particlePos[2 * id] += ddx;
              particlePos[2 * id + 1] += ddy;
            }
          }
        }
      }

      // Wall-particle separation (wall is immovable → 100% correction)
      for (int i = 0; i < numParticles; i++) {
        final distBot = particlePos[2 * i + 1] - bottomWall;
        if (distBot > 0 && distBot < halfDist) {
          particlePos[2 * i + 1] += halfDist - distBot;
        }
        final distLeft = particlePos[2 * i] - leftWall;
        if (distLeft > 0 && distLeft < halfDist) {
          particlePos[2 * i] += halfDist - distLeft;
        }
        final distRight = rightWall - particlePos[2 * i];
        if (distRight > 0 && distRight < halfDist) {
          particlePos[2 * i] -= halfDist - distRight;
        }
        final distTop = topWall - particlePos[2 * i + 1];
        if (distTop > 0 && distTop < halfDist) {
          particlePos[2 * i + 1] -= halfDist - distTop;
        }
      }
    }
  }

  // ── 3. Obstacle + wall collisions ───────────────────────────────
  void handleParticleCollisions(double obstacleX, double obstacleY,
      double obstacleRadius, double obstacleVelX, double obstacleVelY) {
    final r = particleRadius;
    final minDist = obstacleRadius + r;
    final minDist2 = minDist * minDist;
    final wallPad = r + particleGap * 0.5;
    final minX = h + wallPad;
    final maxX = (fNumX - 1) * h - wallPad;
    final minY = h + wallPad;
    final maxY = (fNumY - 1) * h - wallPad;
    const obstacleRepulsion = 3.5;

    for (int i = 0; i < numParticles; i++) {
      double x = particlePos[2 * i];
      double y = particlePos[2 * i + 1];

      // Obstacle collision
      if (obstacleX > -10) {
        final dx = x - obstacleX;
        final dy = y - obstacleY;
        final d2 = dx * dx + dy * dy;
        if (d2 < minDist2 && d2 > 1e-12) {
          final d = sqrt(d2);
          final nx = dx / d, ny = dy / d;

          // Project to surface
          x = obstacleX + nx * minDist;
          y = obstacleY + ny * minDist;

          // Relative velocity
          final relVx = particleVel[2 * i] - obstacleVelX;
          final relVy = particleVel[2 * i + 1] - obstacleVelY;
          final relVn = relVx * nx + relVy * ny;

          // Strip inward normal component
          double outVx = relVx, outVy = relVy;
          if (relVn < 0.0) {
            outVx -= relVn * nx;
            outVy -= relVn * ny;
          }

          // Outward repulsion proportional to penetration
          final overlap = minDist - d;
          final repulse = obstacleRepulsion * (overlap / minDist);
          outVx += repulse * nx;
          outVy += repulse * ny;

          particleVel[2 * i] = outVx + obstacleVelX;
          particleVel[2 * i + 1] = outVy + obstacleVelY;
        }
      }

      // Speed-dependent wall bounce: slow → zero (no jitter), fast → bounce
      if (x < minX) {
        x = minX;
        final v = particleVel[2 * i];
        particleVel[2 * i] = v.abs() < 0.3 ? 0 : v * -0.1;
      }
      if (x > maxX) {
        x = maxX;
        final v = particleVel[2 * i];
        particleVel[2 * i] = v.abs() < 0.3 ? 0 : v * -0.1;
      }
      if (y < minY) {
        y = minY;
        final v = particleVel[2 * i + 1];
        particleVel[2 * i + 1] = v.abs() < 0.3 ? 0 : v * -0.1;
      }
      if (y > maxY) {
        y = maxY;
        final v = particleVel[2 * i + 1];
        particleVel[2 * i + 1] = v.abs() < 0.3 ? 0 : v * -0.1;
      }
      particlePos[2 * i] = x;
      particlePos[2 * i + 1] = y;
    }
  }

  // ── 4. Transfer velocities (P2G / G2P) ─────────────────────────
  void transferVelocities(bool toGrid, double flipRatio) {
    final n = fNumY;
    final h1 = fInvSpacing;
    final h2 = 0.5 * h;

    if (toGrid) {
      prevU.setAll(0, u);
      prevV.setAll(0, v);
      du.fillRange(0, fNumCells, 0.0);
      dv.fillRange(0, fNumCells, 0.0);
      u.fillRange(0, fNumCells, 0.0);
      v.fillRange(0, fNumCells, 0.0);

      // Classify cells
      for (int i = 0; i < fNumCells; i++) {
        cellType[i] = s[i] == 0.0 ? solidCell : airCell;
      }
      for (int i = 0; i < numParticles; i++) {
        final xi = (particlePos[2 * i] * h1).floor().clamp(0, fNumX - 1);
        final yi = (particlePos[2 * i + 1] * h1).floor().clamp(0, fNumY - 1);
        if (cellType[xi * n + yi] == airCell) {
          cellType[xi * n + yi] = fluidCell;
        }
      }
    }

    // Process both components (0=u, 1=v)
    for (int component = 0; component < 2; component++) {
      final ddx = component == 0 ? 0.0 : h2;
      final ddy = component == 0 ? h2 : 0.0;
      final f = component == 0 ? u : v;
      final prevF = component == 0 ? prevU : prevV;
      final d = component == 0 ? du : dv;

      for (int i = 0; i < numParticles; i++) {
        double px = particlePos[2 * i].clamp(h, (fNumX - 1) * h);
        double py = particlePos[2 * i + 1].clamp(h, (fNumY - 1) * h);

        final x0 = max(0, min(((px - ddx) * h1).floor(), fNumX - 2));
        final tx = (((px - ddx) - x0 * h) * h1).clamp(0.0, 1.0);
        final x1 = min(x0 + 1, fNumX - 2);

        final y0 = max(0, min(((py - ddy) * h1).floor(), fNumY - 2));
        final ty = (((py - ddy) - y0 * h) * h1).clamp(0.0, 1.0);
        final y1 = min(y0 + 1, fNumY - 2);

        final sx = 1.0 - tx;
        final sy = 1.0 - ty;
        final d0 = sx * sy, d1 = tx * sy, d2 = tx * ty, d3 = sx * ty;
        final nr0 = x0 * n + y0;
        final nr1 = x1 * n + y0;
        final nr2 = x1 * n + y1;
        final nr3 = x0 * n + y1;

        if (toGrid) {
          final pv = particleVel[2 * i + component];
          f[nr0] += pv * d0;
          d[nr0] += d0;
          f[nr1] += pv * d1;
          d[nr1] += d1;
          f[nr2] += pv * d2;
          d[nr2] += d2;
          f[nr3] += pv * d3;
          d[nr3] += d3;
        } else {
          // G2P: air-cell validity mask
          final offset = component == 0 ? n : 1;
          final v0 = (cellType[nr0] != airCell ||
                  (nr0 >= offset && cellType[nr0 - offset] != airCell))
              ? 1.0
              : 0.0;
          final v1 = (cellType[nr1] != airCell ||
                  (nr1 >= offset && cellType[nr1 - offset] != airCell))
              ? 1.0
              : 0.0;
          final v2 = (cellType[nr2] != airCell ||
                  (nr2 >= offset && cellType[nr2 - offset] != airCell))
              ? 1.0
              : 0.0;
          final v3 = (cellType[nr3] != airCell ||
                  (nr3 >= offset && cellType[nr3 - offset] != airCell))
              ? 1.0
              : 0.0;

          final pv = particleVel[2 * i + component];
          final denom = v0 * d0 + v1 * d1 + v2 * d2 + v3 * d3;
          if (denom > 0.0) {
            final picV =
                (v0 * d0 * f[nr0] + v1 * d1 * f[nr1] + v2 * d2 * f[nr2] + v3 * d3 * f[nr3]) /
                    denom;
            final corr = (v0 * d0 * (f[nr0] - prevF[nr0]) +
                    v1 * d1 * (f[nr1] - prevF[nr1]) +
                    v2 * d2 * (f[nr2] - prevF[nr2]) +
                    v3 * d3 * (f[nr3] - prevF[nr3])) /
                denom;
            final flipV = pv + corr;
            particleVel[2 * i + component] =
                (1.0 - flipRatio) * picV + flipRatio * flipV;
          }
        }
      }

      if (toGrid) {
        // Normalize by weights
        for (int i = 0; i < f.length; i++) {
          if (d[i] > 0.0) f[i] /= d[i];
        }
        // Restore solid cell boundary velocities
        for (int i = 0; i < fNumX; i++) {
          for (int j = 0; j < fNumY; j++) {
            final idx = i * n + j;
            final solid = cellType[idx] == solidCell;
            if (solid || (i > 0 && cellType[(i - 1) * n + j] == solidCell)) {
              final wallFace = i <= 1 || i >= fNumX - 1 || j == 0;
              u[idx] = wallFace ? 0.0 : prevU[idx];
            }
            if (solid || (j > 0 && cellType[i * n + j - 1] == solidCell)) {
              final wallFace = i == 0 || i >= fNumX - 1 || j <= 1;
              v[idx] = wallFace ? 0.0 : prevV[idx];
            }
          }
        }
      }
    }
  }

  // ── 5. Particle density (bilinear splat to cell centers) ────────
  void _updateParticleDensity() {
    final n = fNumY;
    particleDensity.fillRange(0, fNumCells, 0.0);

    for (int i = 0; i < numParticles; i++) {
      final px = particlePos[2 * i].clamp(h, (fNumX - 1) * h);
      final py = particlePos[2 * i + 1].clamp(h, (fNumY - 1) * h);

      final x0 = max(0, min(((px - 0.5 * h) * fInvSpacing).floor(), fNumX - 2));
      final tx = (((px - 0.5 * h) - x0 * h) * fInvSpacing).clamp(0.0, 1.0);
      final x1 = min(x0 + 1, fNumX - 2);

      final y0 = max(0, min(((py - 0.5 * h) * fInvSpacing).floor(), fNumY - 2));
      final ty = (((py - 0.5 * h) - y0 * h) * fInvSpacing).clamp(0.0, 1.0);
      final y1 = min(y0 + 1, fNumY - 2);

      final sx = 1.0 - tx, sy = 1.0 - ty;
      particleDensity[x0 * n + y0] += sx * sy;
      particleDensity[x1 * n + y0] += tx * sy;
      particleDensity[x1 * n + y1] += tx * ty;
      particleDensity[x0 * n + y1] += sx * ty;
    }
  }

  // ── 6. Pressure projection (Gauss-Seidel) ──────────────────────
  void solveIncompressibility(
      int numIters, double dt, double overRelaxation) {
    p.fillRange(0, fNumCells, 0.0);
    // Save post-P2G velocities — THIS is what G2P uses for FLIP delta
    prevU.setAll(0, u);
    prevV.setAll(0, v);

    final n = fNumY;
    final cp = density * h / dt;

    for (int iter = 0; iter < numIters; iter++) {
      for (int i = 1; i < fNumX - 1; i++) {
        for (int j = 1; j < fNumY - 1; j++) {
          if (cellType[i * n + j] != fluidCell) continue;

          final center = i * n + j;
          final left = (i - 1) * n + j;
          final right = (i + 1) * n + j;
          final bottom = i * n + j - 1;
          final top = i * n + j + 1;

          final sx0 = s[left], sx1 = s[right];
          final sy0 = s[bottom], sy1 = s[top];
          final sTotal = sx0 + sx1 + sy0 + sy1;
          if (sTotal == 0.0) continue;

          double div =
              u[right] - u[center] + v[top] - v[center];

          // Density drift compensation
          if (particleRestDensity > 0.0) {
            final compression = particleDensity[center] - particleRestDensity;
            if (compression > 0.0) {
              div -= 1.0 * compression;
            }
          }

          double pCorr = -div / sTotal;
          pCorr *= overRelaxation;
          p[center] += cp * pCorr;

          u[center] -= sx0 * pCorr;
          u[right] += sx1 * pCorr;
          v[center] -= sy0 * pCorr;
          v[top] += sy1 * pCorr;
        }
      }
    }
  }

  // ── 7. Global velocity damping ──────────────────────────────────
  void dampVelocities(double damping) {
    final scale = 1.0 - damping;
    for (int i = 0; i < numParticles; i++) {
      particleVel[2 * i] *= scale;
      particleVel[2 * i + 1] *= scale;
    }
  }

  // ── 8. Settled-particle damping (kills surface jitter) ──────────
  void dampSettledParticles(double threshold, double maxDamp) {
    final threshold2 = threshold * threshold;
    for (int i = 0; i < numParticles; i++) {
      final vx = particleVel[2 * i], vy = particleVel[2 * i + 1];
      final s2 = vx * vx + vy * vy;
      if (s2 < threshold2 && s2 > 0) {
        final speed = sqrt(s2);
        final t = 1.0 - speed / threshold;
        final damp = 1.0 - maxDamp * t;
        particleVel[2 * i] *= damp;
        particleVel[2 * i + 1] *= damp;
      }
    }
  }

  // ── 9. Velocity clamp ───────────────────────────────────────────
  void clampVelocities(double maxSpeed) {
    final maxSpeed2 = maxSpeed * maxSpeed;
    for (int i = 0; i < numParticles; i++) {
      final vx = particleVel[2 * i], vy = particleVel[2 * i + 1];
      final speed2 = vx * vx + vy * vy;
      if (speed2 > maxSpeed2) {
        final s = maxSpeed / sqrt(speed2);
        particleVel[2 * i] *= s;
        particleVel[2 * i + 1] *= s;
      }
    }
  }

  // ── 10. Idle wave (gentle sway — called OUTSIDE simulate) ──────
  void applyIdleWave(double dt, double strength, double frequency, double noise) {
    final rng = Random();
    for (int i = 0; i < numParticles; i++) {
      final px = particlePos[2 * i];
      final py = particlePos[2 * i + 1];
      final phase = frequency * waveTime + 2.5 * py - 0.3 * px;
      particleVel[2 * i] += strength * sin(phase) * dt;
      particleVel[2 * i + 1] += strength * 0.2 * cos(phase * 1.3 + 0.7) * dt;
      if (noise > 0) {
        particleVel[2 * i] += (rng.nextDouble() - 0.5) * noise * dt;
        particleVel[2 * i + 1] +=
            (rng.nextDouble() - 0.5) * noise * dt * 0.3;
      }
    }
    waveTime += dt;
  }
}
