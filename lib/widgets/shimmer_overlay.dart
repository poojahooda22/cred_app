import 'dart:math' show tan, pi;
import 'package:flutter/material.dart';

/// A custom shimmer effect built with CustomPainter + repeating AnimationController.
///
/// This replicates how CRED's NeoPOP shimmer works internally:
/// 1. AnimationController repeats on a cycle
/// 2. A status listener adds a configurable delay between cycles
/// 3. ShimmerPainter draws two parallelogram gradient lines
/// 4. The controller's value drives the x-position across the widget
class ShimmerOverlay extends StatefulWidget {
  final Widget child;
  final Color shimmerColor;
  final double shimmerWidth;
  final double trailingWidthFactor;
  final double gapWidth;
  final Duration duration;
  final Duration delay;
  final double tiltAngle;

  const ShimmerOverlay({
    super.key,
    required this.child,
    this.shimmerColor = const Color.fromRGBO(255, 248, 229, 0.5),
    this.shimmerWidth = 16,
    this.trailingWidthFactor = 0.5,
    this.gapWidth = 8,
    this.duration = const Duration(milliseconds: 2400),
    this.delay = const Duration(milliseconds: 1200),
    this.tiltAngle = 20,
  });

  @override
  State<ShimmerOverlay> createState() => _ShimmerOverlayState();
}

class _ShimmerOverlayState extends State<ShimmerOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _delaying = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    // Status listener loop: forward → delay → forward → delay → ...
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed && !_delaying) {
        _delaying = true;
        Future.delayed(widget.delay, () {
          if (mounted) {
            _delaying = false;
            _controller.forward(from: 0);
          }
        });
      }
    });

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Stack(
        children: [
          widget.child,
          Positioned.fill(
            child: ClipRect(
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, _) {
                  return CustomPaint(
                    painter: _ShimmerPainter(
                      progress: _controller.value,
                      color: widget.shimmerColor,
                      shimmerWidth: widget.shimmerWidth,
                      trailingWidthFactor: widget.trailingWidthFactor,
                      gapWidth: widget.gapWidth,
                      tiltAngleDeg: widget.tiltAngle,
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Draws two parallelogram shimmer lines that sweep left-to-right.
///
/// Main line: full [shimmerWidth]
/// Trailing line: [shimmerWidth * trailingWidthFactor], offset by [gapWidth]
///
/// The tilt is achieved by offsetting top vs bottom x-coordinates
/// using tan(tiltAngle).
class _ShimmerPainter extends CustomPainter {
  final double progress;
  final Color color;
  final double shimmerWidth;
  final double trailingWidthFactor;
  final double gapWidth;
  final double tiltAngleDeg;

  _ShimmerPainter({
    required this.progress,
    required this.color,
    required this.shimmerWidth,
    required this.trailingWidthFactor,
    required this.gapWidth,
    required this.tiltAngleDeg,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final tiltRad = tiltAngleDeg * pi / 180;
    final tiltOffset = size.height * tan(tiltRad);

    // Total travel: from off-screen left to off-screen right
    final totalTravel = size.width + tiltOffset + shimmerWidth * 2 + gapWidth;
    final currentX = -shimmerWidth - tiltOffset + progress * totalTravel;

    // Draw main shimmer line
    _drawParallelogram(
      canvas,
      size,
      xPos: currentX,
      width: shimmerWidth,
      tiltOffset: tiltOffset,
      color: color,
    );

    // Draw trailing (thinner) shimmer line behind the main one
    final trailingWidth = shimmerWidth * trailingWidthFactor;
    _drawParallelogram(
      canvas,
      size,
      xPos: currentX - shimmerWidth - gapWidth,
      width: trailingWidth,
      tiltOffset: tiltOffset,
      color: color.withValues(alpha: (color.a * 0.6)),
    );
  }

  void _drawParallelogram(
    Canvas canvas,
    Size size, {
    required double xPos,
    required double width,
    required double tiltOffset,
    required Color color,
  }) {
    final path = Path()
      // Top-left (shifted right by tilt)
      ..moveTo(xPos + tiltOffset, 0)
      // Top-right
      ..lineTo(xPos + tiltOffset + width, 0)
      // Bottom-right (no tilt shift at bottom)
      ..lineTo(xPos + width, size.height)
      // Bottom-left
      ..lineTo(xPos, size.height)
      ..close();

    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [
          color.withValues(alpha: 0),
          color,
          color,
          color.withValues(alpha: 0),
        ],
        stops: const [0.0, 0.3, 0.7, 1.0],
      ).createShader(
        Rect.fromLTWH(xPos, 0, width + tiltOffset, size.height),
      );

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_ShimmerPainter old) => old.progress != progress;
}