import 'dart:math' as math;

import 'package:chess_rps/common/palette.dart';
import 'package:flutter/material.dart';

class CustomGradient extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final side = size.width;
    final path = Path();

    path.moveTo(0, side);

    final paint = Paint()
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke
      ..color = Colors.red;

    for (double i = -1; i <= 1; i += 0.1) {
      final x = (i + 1) / 2 * side;
      final y = -math.pow(i, 3) * side / 2 + side / 2;

      path.lineTo(x, y);
    }

    canvas.drawPath(path, paint);

    final radialGradient = RadialGradient(
      colors: const [Palette.yellow200, Palette.yellow400],
      radius: side / 8,
      center: Alignment.bottomCenter,
      stops: const [0.1, 0.9],
    );

    final bottomPath = Path()
      ..addPath(path, const Offset(0, 0))
      ..lineTo(side, side);

    final bottomPaint = Paint()
      ..shader = radialGradient.createShader(Rect.fromCenter(
        center: Offset(side / 2, side),
        width: side / 6,
        height: side,
      ));

    canvas.drawPath(bottomPath, bottomPaint);

    const topGradient = LinearGradient(
      colors: [Palette.yellow500, Palette.yellow300],
      begin: Alignment.bottomLeft,
      end: Alignment.topRight,
      stops: [0.5, 1],
    );

    final topPath = Path()
      ..addPath(path, const Offset(0, 0))
      ..lineTo(0, 0);

    final topPaint = Paint()
      ..color = Palette.yellow400
      ..shader = topGradient.createShader(
        Rect.fromCenter(
          center: Offset(0, side),
          width: side,
          height: side / 6,
        ),
      );

    canvas.drawPath(topPath, topPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
