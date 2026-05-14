import 'package:flutter/material.dart';

class EmvChipWidget extends StatelessWidget {
  const EmvChipWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 42,
      height: 32,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFF3D275), // Light gold
            Color(0xFFC79833), // Dark gold
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: CustomPaint(
        painter: _EmvChipPainter(),
      ),
    );
  }
}

class _EmvChipPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;

    final Paint linePaint = Paint()
      ..style = PaintingStyle.stroke
      ..color = const Color(0x773A2300) // Dark brownish lines
      ..strokeWidth = 0.8
      ..isAntiAlias = true;

    // Center rectangle
    final Rect centerRect = Rect.fromCenter(
      center: Offset(w / 2, h / 2),
      width: w * 0.4,
      height: h * 0.55,
    );
    canvas.drawRRect(
        RRect.fromRectAndRadius(centerRect, const Radius.circular(3)),
        linePaint);

    // Left lines
    canvas.drawLine(Offset(0, h * 0.25), Offset(centerRect.left, h * 0.25), linePaint);
    canvas.drawLine(Offset(0, h * 0.5), Offset(centerRect.left, h * 0.5), linePaint);
    canvas.drawLine(Offset(0, h * 0.75), Offset(centerRect.left, h * 0.75), linePaint);

    // Right lines
    canvas.drawLine(Offset(centerRect.right, h * 0.25), Offset(w, h * 0.25), linePaint);
    canvas.drawLine(Offset(centerRect.right, h * 0.5), Offset(w, h * 0.5), linePaint);
    canvas.drawLine(Offset(centerRect.right, h * 0.75), Offset(w, h * 0.75), linePaint);

    // Optional top/bottom vertical lines
    canvas.drawLine(Offset(w * 0.35, 0), Offset(w * 0.35, centerRect.top), linePaint);
    canvas.drawLine(Offset(w * 0.65, 0), Offset(w * 0.65, centerRect.top), linePaint);
    canvas.drawLine(Offset(w * 0.35, h), Offset(w * 0.35, centerRect.bottom), linePaint);
    canvas.drawLine(Offset(w * 0.65, h), Offset(w * 0.65, centerRect.bottom), linePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
