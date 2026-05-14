import 'package:flutter/material.dart';

class NeuWatermarkWidget extends StatelessWidget {
  const NeuWatermarkWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _NeuWatermarkPainter(),
    );
  }
}

class _NeuWatermarkPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;

    final Paint paint = Paint()
      ..style = PaintingStyle.stroke
      ..color = Colors.white.withOpacity(0.08) // Slightly more visible
      ..strokeWidth = h * 0.22 // Slightly less thick to make it elegant
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..isAntiAlias = true;

    final Path path = Path();
    
    // Smooth wavy 'N' shape matching the Neu card logo
    // Left stem starts higher up (shorter than the right stem)
    path.moveTo(w * 0.30, h * 0.55);
    
    // Upward sweep to top of diagonal
    path.lineTo(w * 0.45, h * 0.25);
    
    // Diagonal down-right, goes the lowest
    path.lineTo(w * 0.58, h * 0.80);
    
    // Upward sweep right stem, goes high
    path.lineTo(w * 0.75, h * 0.28);

    // Apply a slight rotation to make it feel more dynamic and italic
    canvas.translate(w * 0.5, h * 0.5);
    canvas.rotate(0.12); // Slightly less tilt
    canvas.translate(-w * 0.5, -h * 0.5);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
