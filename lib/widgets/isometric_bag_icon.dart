import 'package:flutter/material.dart';

class IsometricBagIcon extends StatelessWidget {
  final double size;
  const IsometricBagIcon({super.key, this.size = 24});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _IsometricBagPainter(),
    );
  }
}

class _IsometricBagPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;
    
    // Adjusted proportions for a much flatter, thinner oblique 3D bag
    final double fw = w * 0.52;  // Front face width (slightly narrower)
    final double fh = h * 0.48;  // Front face height
    final double d = w * 0.12;   // Very thin depth

    // Center the drawing, accounting for the rotation and depth shift
    canvas.translate(w * 0.5 + d / 2, h * 0.5 - d / 2 + h * 0.1);
    canvas.rotate(-0.25); // Tilt by roughly -14 degrees
    
    // Perfectly matched light colors
    final Color frontColor = const Color(0xFFC0FEE0); // Very light mint front
    final Color sideColor = const Color(0xFF6DE8A8);  // Medium mint sides
    final Color strokeColor = const Color(0xFF007B40); // Dark green outline
    final Color heartColor = const Color(0xFF007B40);  // Dark green heart

    final Paint fillPaint = Paint()
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    final Paint strokePaint = Paint()
      ..style = PaintingStyle.stroke
      ..color = strokeColor
      ..strokeWidth = w * 0.05
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round
      ..isAntiAlias = true;

    // Vertices for the Front Face
    final Offset fTL = Offset(-fw / 2, -fh / 2);
    final Offset fTR = Offset(fw / 2, -fh / 2);
    final Offset fBL = Offset(-fw / 2, fh / 2);
    final Offset fBR = Offset(fw / 2, fh / 2);

    // Vertices for the Back Face (shifted down and left)
    final Offset bTL = Offset(-fw / 2 - d, -fh / 2 + d);
    final Offset bTR = Offset(fw / 2 - d, -fh / 2 + d);
    final Offset bBL = Offset(-fw / 2 - d, fh / 2 + d);
    final Offset bBR = Offset(fw / 2 - d, fh / 2 + d);

    // Left face polygon
    final Path leftFace = Path()
      ..moveTo(fTL.dx, fTL.dy)
      ..lineTo(bTL.dx, bTL.dy)
      ..lineTo(bBL.dx, bBL.dy)
      ..lineTo(fBL.dx, fBL.dy)
      ..close();

    // Bottom face polygon
    final Path bottomFace = Path()
      ..moveTo(fBL.dx, fBL.dy)
      ..lineTo(bBL.dx, bBL.dy)
      ..lineTo(bBR.dx, bBR.dy)
      ..lineTo(fBR.dx, fBR.dy)
      ..close();

    // Front face polygon
    final Path frontFace = Path()
      ..moveTo(fTL.dx, fTL.dy)
      ..lineTo(fTR.dx, fTR.dy)
      ..lineTo(fBR.dx, fBR.dy)
      ..lineTo(fBL.dx, fBL.dy)
      ..close();

    // Handles
    final double handleRise = fh * 0.55;
    
    // Back handle
    final Path backHandle = Path()
      ..moveTo(bTL.dx + fw * 0.25, bTL.dy)
      ..quadraticBezierTo(
          bTL.dx + fw * 0.5, bTL.dy - handleRise, bTR.dx - fw * 0.25, bTR.dy);
          
    // Front handle
    final Path frontHandle = Path()
      ..moveTo(fTL.dx + fw * 0.25, fTL.dy)
      ..quadraticBezierTo(
          fTL.dx + fw * 0.5, fTL.dy - handleRise, fTR.dx - fw * 0.25, fTR.dy);

    // Draw Back Handle
    canvas.drawPath(backHandle, strokePaint);

    // Draw Left Face
    fillPaint.color = sideColor;
    canvas.drawPath(leftFace, fillPaint);
    canvas.drawPath(leftFace, strokePaint);

    // Draw Bottom Face
    fillPaint.color = sideColor;
    canvas.drawPath(bottomFace, fillPaint);
    canvas.drawPath(bottomFace, strokePaint);

    // Draw Front Face
    fillPaint.color = frontColor;
    canvas.drawPath(frontFace, fillPaint);
    canvas.drawPath(frontFace, strokePaint);

    // Draw Front Handle
    canvas.drawPath(frontHandle, strokePaint);

    // Draw Heart on Front Face
    final double hw = fw * 0.28;
    final Path heartPath = Path()
      ..moveTo(0, hw * 0.4)
      ..cubicTo(-hw * 1.0, -hw * 0.2, -hw * 0.5, -hw * 1.0, 0, -hw * 0.3)
      ..cubicTo(hw * 0.5, -hw * 1.0, hw * 1.0, -hw * 0.2, 0, hw * 0.4);
      
    fillPaint.color = heartColor;
    canvas.drawPath(heartPath, fillPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
