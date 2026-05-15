import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:sensors_plus/sensors_plus.dart';

import '../simulation/flip_fluid.dart';

class FluidSimulationWidget extends StatefulWidget {
  final double height;
  const FluidSimulationWidget({super.key, this.height = 420});

  @override
  State<FluidSimulationWidget> createState() => _FluidSimulationWidgetState();
}

class _FluidSimulationWidgetState extends State<FluidSimulationWidget>
    with SingleTickerProviderStateMixin {
  FlipFluid? _fluid;
  bool _isPlaying = false;
  bool _initialized = false;

  late final Ticker _ticker;
  final _repaint = ValueNotifier<int>(0);

  // Touch obstacle
  double _obstacleX = -100, _obstacleY = -100;
  double _prevObstacleX = -100, _prevObstacleY = -100;
  double _obstacleVelX = 0, _obstacleVelY = 0;
  bool _touching = false;

  // Accelerometer tilt
  StreamSubscription<AccelerometerEvent>? _accelSub;
  double _tiltX = 0.0;

  // View mapping
  double _scale = 1.0;
  double _viewLeft = 0.0;
  double _viewBottom = 0.0;
  double _particleScreenRadius = 3.0;

  // Sim constants (matching the original mobile path exactly)
  static const double _simHeight = 3.0;
  static const double _gapPx = 6.5; // (6.5 - 5) / cScale ≈ 1px visible gap
  static const double _targetRadiusPx = 5.0; // mobile: ~6px rendered diameter
  static const double _density = 1000.0;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_onTick);
  }

  @override
  void dispose() {
    _ticker.dispose();
    _accelSub?.cancel();
    _repaint.dispose();
    super.dispose();
  }

  void _initFluid(double widthPx) {
    if (_initialized) return;
    _initialized = true;

    final heightPx = widget.height;
    final cScale = heightPx / _simHeight;
    final simWidth = widthPx / cScale;

    // Grid resolution from target rendered particle size
    // r/h = 0.3 keeps FLIP grid coupling stable (original formula)
    final res = (0.3 * heightPx / _targetRadiusPx).round();
    final tankH = 1.0 * _simHeight;
    final tankW = 1.0 * simWidth;
    final h = tankH / res;
    final r = 0.3 * h;

    // Mobile gap: original uses (GAP_PX - 5) / cScale → NEGATIVE on mobile
    // This makes particles pack tighter than 2r — critical for fluid density
    final gapSim = (_gapPx - 5) / cScale;

    // Particle count from full-tank hex capacity
    final wallPad = r + gapSim * 0.5;
    final minDistSpawn = 2.0 * r + gapSim;
    final dx = minDistSpawn;
    final fullNumX = ((tankW - 2.0 * h - 2.0 * wallPad) / dx).round();
    final fullNumY = ((tankH - h - 2.0 * wallPad) / (dx * 0.866)).round();
    final tankCapacity = fullNumX * fullNumY;
    final targetParticles = (0.45 * tankCapacity).floor() + 400;
    final maxParticles = (targetParticles * 2.5).ceil();

    _fluid = FlipFluid(
      density: _density,
      width: tankW,
      height: tankH,
      spacing: h,
      particleRadius: r,
      particleGap: gapSim, // allow negative — original does this on mobile
      maxParticles: maxParticles.clamp(500, 8000),
    );

    // Map the fluid domain (excluding solid boundary cells) to the full widget
    final fluidW = (_fluid!.fNumX - 2) * _fluid!.h;
    _scale = widthPx / fluidW;
    _viewLeft = _fluid!.h;     // skip left boundary cell
    _viewBottom = _fluid!.h;   // skip bottom boundary cell
    _particleScreenRadius = r * _scale;
  }

  void _startSimulation() {
    if (_fluid == null) return;
    _fluid!.spawnHexPacked(relWaterWidth: 1.0, relWaterHeight: 0.45);
    setState(() => _isPlaying = true);
    _ticker.start();
    _startAccelerometer();
  }

  void _startAccelerometer() {
    try {
      _accelSub = accelerometerEventStream(
        samplingPeriod: const Duration(milliseconds: 32),
      ).listen((event) {
        final raw = -event.x;
        // Deadzone + clamp + scale (matching original: 3° deadzone, ±30°, scale 5.0)
        if (raw.abs() < 0.5) {
          _tiltX = 0.0;
        } else {
          _tiltX = (raw.clamp(-5.0, 5.0));
        }
      });
    } catch (_) {
      // Sensors not available
    }
  }

  void _onTick(Duration elapsed) {
    if (!_isPlaying || _fluid == null) return;
    final f = _fluid!;
    const dt = 1.0 / 60.0;

    // Compute obstacle velocity from position delta
    if (_touching) {
      _obstacleVelX = (_obstacleX - _prevObstacleX) / dt;
      _obstacleVelY = (_obstacleY - _prevObstacleY) / dt;
      // EMA smooth + clamp (matching original)
      _obstacleVelX = _obstacleVelX.clamp(-12.0, 12.0);
      _obstacleVelY = _obstacleVelY.clamp(-12.0, 12.0);
      _prevObstacleX = _obstacleX;
      _prevObstacleY = _obstacleY;
    }

    f.simulate(
      dt: dt,
      gravity: -9.81,
      flipRatio: 0.90,
      numPressureIters: 80,
      numParticleIters: 3,
      overRelaxation: 1.9,
      obstacleX: _touching ? _obstacleX : -100,
      obstacleY: _touching ? _obstacleY : -100,
      obstacleRadius: 0.25,
      obstacleVelX: _touching ? _obstacleVelX : 0,
      obstacleVelY: _touching ? _obstacleVelY : 0,
      tiltForceX: _tiltX,
    );

    // Idle wave AFTER simulate (so pressure solver doesn't cancel it)
    if (f.frameCount > 120) {
      final ramp = ((f.frameCount - 120) / 60.0).clamp(0.0, 1.0);
      f.applyIdleWave(dt, 0.60 * ramp, 3.2, 0.06 * ramp);
    }

    _repaint.value++;
  }

  Offset _screenToSim(Offset screen) {
    return Offset(
      screen.dx / _scale + _viewLeft,
      (widget.height - screen.dy) / _scale + _viewBottom,
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        _initFluid(width);

        return GestureDetector(
          onPanStart: (d) {
            _touching = true;
            final sim = _screenToSim(d.localPosition);
            _obstacleX = sim.dx;
            _obstacleY = sim.dy;
            _prevObstacleX = _obstacleX;
            _prevObstacleY = _obstacleY;
            _obstacleVelX = 0;
            _obstacleVelY = 0;
          },
          onPanUpdate: (d) {
            final sim = _screenToSim(d.localPosition);
            _obstacleX = sim.dx;
            _obstacleY = sim.dy;
          },
          onPanEnd: (_) {
            _touching = false;
            _obstacleVelX = 0;
            _obstacleVelY = 0;
          },
          onPanCancel: () {
            _touching = false;
            _obstacleVelX = 0;
            _obstacleVelY = 0;
          },
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Container(
              width: width,
              height: widget.height,
              color: const Color(0xFF141414), // one step lighter than app bg (0x0A)
              child: Stack(
                children: [
                  if (_fluid != null)
                    RepaintBoundary(
                      child: CustomPaint(
                        size: Size(width, widget.height),
                        painter: _FluidPainter(
                          fluid: _fluid!,
                          repaint: _repaint,
                          scale: _scale,
                          viewLeft: _viewLeft,
                          viewBottom: _viewBottom,
                          containerHeight: widget.height,
                          particleScreenRadius: _particleScreenRadius,
                        ),
                      ),
                    ),
                  if (!_isPlaying)
                    Positioned.fill(
                      child: _PlayOverlay(onPlay: _startSimulation),
                    ),
                  if (_touching && _isPlaying)
                    Positioned(
                      left: (_obstacleX - _viewLeft) * _scale - 18,
                      top: widget.height -
                          (_obstacleY - _viewBottom) * _scale -
                          18,
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.2),
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _PlayOverlay extends StatelessWidget {
  final VoidCallback onPlay;
  const _PlayOverlay({required this.onPlay});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onTap: onPlay,
              child: Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.3),
                    width: 1.5,
                  ),
                  color: Colors.white.withValues(alpha: 0.08),
                ),
                child: const Icon(
                  Icons.play_arrow_rounded,
                  color: Colors.white,
                  size: 36,
                ),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              'tap to play',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.4),
                fontSize: 12,
                fontWeight: FontWeight.w500,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FluidPainter extends CustomPainter {
  final FlipFluid fluid;
  final double scale;
  final double viewLeft, viewBottom;
  final double containerHeight;
  final double particleScreenRadius;

  _FluidPainter({
    required this.fluid,
    required ValueNotifier<int> repaint,
    required this.scale,
    required this.viewLeft,
    required this.viewBottom,
    required this.containerHeight,
    required this.particleScreenRadius,
  }) : super(repaint: repaint);

  @override
  void paint(Canvas canvas, Size size) {
    final n = fluid.numParticles;
    if (n == 0) return;

    final paint = Paint()
      ..color = const Color(0xD9FFFFFF)
      ..style = PaintingStyle.fill;

    final r = particleScreenRadius - 1.0;

    for (int i = 0; i < n; i++) {
      final sx = (fluid.particlePos[i * 2] - viewLeft) * scale;
      final sy =
          containerHeight - (fluid.particlePos[i * 2 + 1] - viewBottom) * scale;
      canvas.drawCircle(Offset(sx, sy), r, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _FluidPainter old) => false;
}
