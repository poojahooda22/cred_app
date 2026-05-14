import 'package:flutter/material.dart';

class StoreDealsBagIcon extends StatelessWidget {
  final double size;
  const StoreDealsBagIcon({super.key, this.size = 24});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _StoreDealsBagPainter(),
    );
  }
}

class _StoreDealsBagPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;
    
    // Make the bag much larger relative to the canvas
    final double fw = w * 0.65;
    final double fh = h * 0.55;
    final double d = w * 0.12;
    
    // Shift it down and right to center it optimally inside the box
    canvas.translate(w * 0.5 + d / 2, h * 0.5 - d / 2 + h * 0.08);
    canvas.rotate(-0.22); // Pronounced tilt matching the reference
    
    final Color frontColor = const Color(0xFFF5F5F5); // Bright white
    final Color sideColor = const Color(0xFF8E8E93);  // Clear light gray
    final Color bottomColor = const Color(0xFF3A3A3C); // Dark gray
    final Color strokeColor = const Color(0xFF1C1C1E); // Crisp dark outline
    final Color heartColor = const Color(0xFFA1A1A6);  // Visible gray heart

    final Paint fillPaint = Paint()..style = PaintingStyle.fill..isAntiAlias = true;
    final Paint strokePaint = Paint()
      ..style = PaintingStyle.stroke
      ..color = strokeColor
      ..strokeWidth = w * 0.05 // Crisper, thinner lines
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round
      ..isAntiAlias = true;

    final Offset fTL = Offset(-fw / 2, -fh / 2);
    final Offset fTR = Offset(fw / 2, -fh / 2);
    final Offset fBL = Offset(-fw / 2, fh / 2);
    final Offset fBR = Offset(fw / 2, fh / 2);

    final Offset bTL = Offset(-fw / 2 - d, -fh / 2 + d);
    final Offset bTR = Offset(fw / 2 - d, -fh / 2 + d);
    final Offset bBL = Offset(-fw / 2 - d, fh / 2 + d);
    final Offset bBR = Offset(fw / 2 - d, fh / 2 + d);

    final Path leftFace = Path()..moveTo(fTL.dx, fTL.dy)..lineTo(bTL.dx, bTL.dy)..lineTo(bBL.dx, bBL.dy)..lineTo(fBL.dx, fBL.dy)..close();
    final Path bottomFace = Path()..moveTo(fBL.dx, fBL.dy)..lineTo(bBL.dx, bBL.dy)..lineTo(bBR.dx, bBR.dy)..lineTo(fBR.dx, fBR.dy)..close();
    final Path frontFace = Path()..moveTo(fTL.dx, fTL.dy)..lineTo(fTR.dx, fTR.dy)..lineTo(fBR.dx, fBR.dy)..lineTo(fBL.dx, fBL.dy)..close();

    final double handleRise = fh * 0.5;
    
    final Path backHandle = Path()
      ..moveTo(bTL.dx + fw * 0.25, bTL.dy)
      ..quadraticBezierTo(bTL.dx + fw * 0.5, bTL.dy - handleRise, bTR.dx - fw * 0.25, bTR.dy);
          
    final Path frontHandle = Path()
      ..moveTo(fTL.dx + fw * 0.25, fTL.dy)
      ..quadraticBezierTo(fTL.dx + fw * 0.5, fTL.dy - handleRise, fTR.dx - fw * 0.25, fTR.dy);

    canvas.drawPath(backHandle, strokePaint);
    
    fillPaint.color = sideColor;
    canvas.drawPath(leftFace, fillPaint);
    canvas.drawPath(leftFace, strokePaint);
    
    fillPaint.color = bottomColor;
    canvas.drawPath(bottomFace, fillPaint);
    canvas.drawPath(bottomFace, strokePaint);
    
    fillPaint.color = frontColor;
    canvas.drawPath(frontFace, fillPaint);
    canvas.drawPath(frontFace, strokePaint);
    
    canvas.drawPath(frontHandle, strokePaint);

    final double hw = fw * 0.35; // Larger prominent heart
    final Path heartPath = Path()
      ..moveTo(0, hw * 0.35)
      ..cubicTo(-hw * 1.0, -hw * 0.25, -hw * 0.5, -hw * 1.0, 0, -hw * 0.3)
      ..cubicTo(hw * 0.5, -hw * 1.0, hw * 1.0, -hw * 0.25, 0, hw * 0.35);
      
    fillPaint.color = heartColor;
    canvas.drawPath(heartPath, fillPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
