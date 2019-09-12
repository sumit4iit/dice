import 'package:flutter/material.dart';

class ConcentricCircle {
  Offset center;
  double innerRadius;
  double outerRadius;
  double strokeWidth;
  final Color color;

  ConcentricCircle(
      {this.center,
        this.innerRadius = 50,
        this.outerRadius = 60,
        this.strokeWidth = 10,
        this.color = Colors.blue});
}


class CirclePainter extends CustomPainter {
  Iterable<ConcentricCircle> concentricCircles;

  CirclePainter({this.concentricCircles});

  @override
  void paint(Canvas canvas, Size size) {
    for (ConcentricCircle concentricCircle in this.concentricCircles) {
      Paint solidCirclePaint = new Paint()
        ..color = concentricCircle.color.withAlpha(90)
        ..strokeWidth = concentricCircle.strokeWidth
        ..style = PaintingStyle.fill;
      canvas.drawCircle(concentricCircle.center, concentricCircle.innerRadius,
          solidCirclePaint);

      Paint concentricArc = new Paint()
        ..color = concentricCircle.color
        ..style = PaintingStyle.stroke
        ..strokeWidth = concentricCircle.strokeWidth
        ..strokeCap = StrokeCap.round;
      canvas.drawCircle(
          concentricCircle.center, concentricCircle.outerRadius, concentricArc);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
