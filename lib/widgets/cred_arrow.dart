import 'package:flutter/material.dart';

class CredArrow extends StatelessWidget {
  final double length;
  final double headSize;
  final double strokeWidth;
  final Color color;
  final bool isBack;

  const CredArrow({
    super.key,
    this.length = 24.0,
    this.headSize = 6.0,
    this.strokeWidth = 1.2,
    this.color = Colors.white,
    this.isBack = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: length,
      height: headSize * 2,
      child: CustomPaint(
        painter: _ArrowPainter(
          color: color,
          strokeWidth: strokeWidth,
          headSize: headSize,
          isBack: isBack,
        ),
      ),
    );
  }
}

class _ArrowPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double headSize;
  final bool isBack;

  _ArrowPainter({
    required this.color,
    required this.strokeWidth,
    required this.headSize,
    required this.isBack,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..isAntiAlias = true;
      
    final double w = size.width;
    final double h = size.height;
    final double midY = h / 2;

    final path = Path();
    if (isBack) {
      // Main stem
      path.moveTo(w, midY);
      path.lineTo(0, midY);
      // Arrow head
      path.moveTo(headSize, midY - headSize * 0.8);
      path.lineTo(0, midY);
      path.lineTo(headSize, midY + headSize * 0.8);
    } else {
      // Main stem
      path.moveTo(0, midY);
      path.lineTo(w, midY);
      // Arrow head
      path.moveTo(w - headSize, midY - headSize * 0.8);
      path.lineTo(w, midY);
      path.lineTo(w - headSize, midY + headSize * 0.8);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
