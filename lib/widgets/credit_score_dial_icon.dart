import 'package:flutter/material.dart';
import 'dart:math' as math;

class CreditScoreDialIcon extends StatelessWidget {
  final double size;
  const CreditScoreDialIcon({super.key, this.size = 24});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _CreditScoreDialPainter(),
    );
  }
}

class _CreditScoreDialPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;
    
    final double radius = w * 0.42;
    final double d = w * 0.12; // Depth
    
    canvas.translate(w * 0.5 + d / 2, h * 0.5 - d / 2);
    canvas.rotate(-0.15); // Tilt to match the bag

    final Color frontColor = const Color(0xFFF5F5F5); // White/Off-white
    final Color sideColor = const Color(0xFF6E6E73);  // Dark Gray
    final Color strokeColor = const Color(0xFF1A1A1A); // Black outline
    final Color needleColor = const Color(0xFF1A1A1A); // Black needle
    final Color accentArcColor = const Color(0xFFD4D4D6); // Light gray arc

    final Paint fillPaint = Paint()..style = PaintingStyle.fill..isAntiAlias = true;
    final Paint strokePaint = Paint()
      ..style = PaintingStyle.stroke
      ..color = strokeColor
      ..strokeWidth = w * 0.04
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round
      ..isAntiAlias = true;

    final Offset centerFront = Offset.zero;
    final Offset centerBack = Offset(-d, d);

    // Tangent points
    final double shiftAngle = math.atan2(d, -d); // 135 degrees
    final double tA = shiftAngle - math.pi / 2;  // 45 degrees
    final double tB = shiftAngle + math.pi / 2;  // 225 degrees

    final Offset p1Front = Offset(radius * math.cos(tA), radius * math.sin(tA));
    final Offset p2Front = Offset(radius * math.cos(tB), radius * math.sin(tB));
    final Offset p1Back = p1Front + centerBack;
    final Offset p2Back = p2Front + centerBack;

    // Draw the 3D side hull
    final Path sideHull = Path()
      ..moveTo(p1Front.dx, p1Front.dy)
      ..lineTo(p1Back.dx, p1Back.dy)
      ..arcToPoint(p2Back, radius: Radius.circular(radius), clockwise: true)
      ..lineTo(p2Front.dx, p2Front.dy)
      ..close();

    fillPaint.color = sideColor;
    canvas.drawPath(sideHull, fillPaint);
    canvas.drawPath(sideHull, strokePaint);

    // Front Circle
    fillPaint.color = frontColor;
    canvas.drawCircle(centerFront, radius, fillPaint);
    canvas.drawCircle(centerFront, radius, strokePaint);

    // Inner dial details
    final double innerRadius = radius * 0.7;
    
    // Thick arc gauge
    final Paint arcPaint = Paint()
      ..style = PaintingStyle.stroke
      ..color = accentArcColor
      ..strokeWidth = w * 0.15
      ..strokeCap = StrokeCap.butt;

    canvas.drawArc(
      Rect.fromCircle(center: centerFront, radius: innerRadius),
      math.pi * 0.6, // start angle
      math.pi * 0.8, // sweep
      false,
      arcPaint,
    );
    
    // Thin inner circle stroke
    canvas.drawCircle(centerFront, innerRadius, strokePaint..strokeWidth = w * 0.02);

    // Needle
    final double needleAngle = -math.pi * 0.15; 
    final double needleLength = radius * 0.65;
    final Offset needleTip = Offset(needleLength * math.cos(needleAngle), needleLength * math.sin(needleAngle));
    
    final Paint needlePaint = Paint()
      ..style = PaintingStyle.stroke
      ..color = needleColor
      ..strokeWidth = w * 0.06
      ..strokeCap = StrokeCap.round;
      
    canvas.drawLine(Offset.zero, needleTip, needlePaint);
    
    // Center dot
    canvas.drawCircle(Offset.zero, w * 0.08, fillPaint..color = strokeColor);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
