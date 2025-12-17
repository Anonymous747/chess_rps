import 'dart:math' as math;

import 'package:chess_rps/common/enum.dart';
import 'package:chess_rps/common/palette.dart';
import 'package:flutter/material.dart';

const _darkPalette = [
  Palette.purple700,
  Palette.purple800,
  Palette.purple800,
  Palette.purple900,
  Palette.purple900
];

const _lightPalette = [
  Palette.white100,
  Palette.white200,
  Palette.white200,
  Palette.white300,
  Palette.white300
];

class CustomGradient extends CustomPainter {
  final Side cellSide;

  const CustomGradient({required this.cellSide});

  @override
  void paint(Canvas canvas, Size size) {
    final palette = cellSide == Side.light ? _lightPalette : _darkPalette;

    final side = size.width;

    final path = Path()..moveTo(0, side);

    final paint = Paint()
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke
      ..color = palette[2];

    for (double i = -1; i <= 1; i += 0.1) {
      final x = (i + 1) / 2 * side;
      final y = -math.pow(i, 3) * side / 2 + side / 2;

      path.lineTo(x, y);
    }

    canvas.drawPath(path, paint);

    final radialGradient = RadialGradient(
      colors: [palette[0], palette[2]],
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

    final topGradient = LinearGradient(
      colors: [palette[3], palette[1]],
      begin: Alignment.bottomLeft,
      end: Alignment.topRight,
      stops: const [0.5, 1],
    );

    final topPath = Path()
      ..addPath(path, const Offset(0, 0))
      ..lineTo(0, 0);

    final topPaint = Paint()
      ..color = palette[3]
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
