import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Islamic 8-point star geometric pattern.
class PatternPainter extends CustomPainter {
  final Color color;
  const PatternPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    const step = 38.0;
    for (double x = 0; x < size.width + step; x += step) {
      for (double y = 0; y < size.height + step; y += step) {
        _star(canvas, Offset(x, y), step * 0.46, paint);
      }
    }
  }

  void _star(Canvas canvas, Offset c, double r, Paint paint) {
    for (int k = 0; k < 2; k++) {
      final path = Path();
      for (int i = 0; i < 4; i++) {
        final a = (math.pi / 2) * i + (k * math.pi / 4);
        final pt = Offset(c.dx + r * math.cos(a), c.dy + r * math.sin(a));
        if (i == 0) {
          path.moveTo(pt.dx, pt.dy);
        } else {
          path.lineTo(pt.dx, pt.dy);
        }
      }
      path.close();
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant PatternPainter oldDelegate) =>
      oldDelegate.color != color;
}
