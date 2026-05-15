import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:neopop/neopop.dart';
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

  // Sim constants
  static const double _simHeight = 3.0;
  static const double _gapPx = 6.5;
  static const double _targetRadiusPx = 5.0;
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

    final res = (0.3 * heightPx / _targetRadiusPx).round();
    final tankH = 1.0 * _simHeight;
    final tankW = 1.0 * simWidth;
    final h = tankH / res;
    final r = 0.3 * h;
    final gapSim = (_gapPx - 5) / cScale;

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
      particleGap: gapSim,
      maxParticles: maxParticles.clamp(500, 8000),
    );

    final fluidW = (_fluid!.fNumX - 2) * _fluid!.h;
    _scale = widthPx / fluidW;
    _viewLeft = _fluid!.h;
    _viewBottom = _fluid!.h;
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
        if (raw.abs() < 0.5) {
          _tiltX = 0.0;
        } else {
          _tiltX = raw.clamp(-5.0, 5.0);
        }
      });
    } catch (_) {}
  }

  void _onTick(Duration elapsed) {
    if (!_isPlaying || _fluid == null) return;
    final f = _fluid!;
    const dt = 1.0 / 60.0;

    if (_touching) {
      _obstacleVelX = ((_obstacleX - _prevObstacleX) / dt).clamp(-12.0, 12.0);
      _obstacleVelY = ((_obstacleY - _prevObstacleY) / dt).clamp(-12.0, 12.0);
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
          // No card, no border — transparent, particles render on page background
          child: SizedBox(
            width: width,
            height: widget.height,
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
              ],
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
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "you've reached the end",
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.2),
              fontSize: 13,
              fontWeight: FontWeight.w500,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'must be bored.',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.35),
              fontSize: 15,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 20),
          NeoPopButton(
            color: Colors.white,
            onTapUp: () {
              HapticFeedback.mediumImpact();
              onPlay();
            },
            onTapDown: () => HapticFeedback.lightImpact(),
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 28, vertical: 12),
              child: Text(
                "let's play",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
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
