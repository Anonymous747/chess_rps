import 'dart:math' as math;

import 'package:chess_rps/common/enum.dart';
import 'package:chess_rps/presentation/utils/board_theme_utils.dart';
import 'package:flutter/material.dart';

class CustomGradient extends CustomPainter {
  final Side cellSide;
  final String boardTheme;

  const CustomGradient({
    required this.cellSide,
    this.boardTheme = 'glass_dark',
  });

  List<Color> _getDarkPalette() {
    final colors = BoardThemeUtils.getDarkPalette(boardTheme);
    return colors.map((color) => Color(color)).toList();
  }

  List<Color> _getLightPalette() {
    final colors = BoardThemeUtils.getLightPalette(boardTheme);
    return colors.map((color) => Color(color)).toList();
  }

  @override
  void paint(Canvas canvas, Size size) {
    final palette = cellSide == Side.light ? _getLightPalette() : _getDarkPalette();

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
  bool shouldRepaint(covariant CustomGradient oldDelegate) {
    // Repaint if board theme or cell side changes
    return oldDelegate.boardTheme != boardTheme || oldDelegate.cellSide != cellSide;
  }
}
