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
      radius: side / 6,
      center: Alignment.bottomCenter,
    );

    // final radialPaint = Paint()
    //   ..shader = radialGradient.createShader(Rect.fromCenter(
    //       center: Offset(side / 2, 0), width: side / 4, height: side / 4));
    // canvas.drawPaint(radialPaint);

    final gradient2 = LinearGradient(
      colors: [Palette.yellow800, Palette.yellow400],
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
    );

    final path1 = Path();
    path1.addPath(path, const Offset(0, 0));
    path1.lineTo(side, side);

    final paint1 = Paint()
      ..shader = radialGradient.createShader(Rect.fromCenter(
          center: Offset(side / 2, side), width: side / 6, height: side));

    canvas.drawPath(path1, paint1);

    final path2 = Path()
      ..addPath(path, const Offset(0, 0))
      ..lineTo(0, 0);

    final paint2 = Paint()
      ..color = Palette.yellow400
      ..shader = gradient2.createShader(
          Rect.fromCenter(center: Offset(0, side), width: side, height: side));

    canvas.drawPath(path2, paint2);

    // final radialPath = Path()..moveTo(side / 2, side);
    // radialPath..moveTo(side / 2, side)..;

    // canvas.drawPath(radialPath, radialPaint);

    //   final path = Path();
    //   path.addArc(
    //     Rect.fromCenter(
    //         center: Offset(side / 2, side), width: side, height: side),
    //     math.pi,
    //     math.pi / 2,
    //   );
    //
    //   final gradient2 = LinearGradient(
    //     colors: [Colors.black, Colors.yellow],
    //     begin: Alignment.topLeft,
    //     end: Alignment.bottomRight,
    //   );
    //
    //   path.addArc(
    //     Rect.fromCenter(center: Offset(side / 2, 0), width: side, height: side),
    //     0,
    //     math.pi / 2,
    //   );
    //
    //   final paint = Paint()
    //     ..strokeWidth = 1
    //     ..style = PaintingStyle.stroke
    //     ..color = Colors.red
    //     ..shader = gradient2.createShader(
    //         Rect.fromPoints(Offset(0, 0), Offset(size.width, size.height / 2)));
    //
    //   canvas.drawPath(path, paint);
    //
    //   final paint1 = Paint()
    //     ..strokeWidth = 1
    //     ..color = Colors.red
    //     ..shader = gradient2.createShader(
    //         Rect.fromPoints(Offset(0, 0), Offset(size.width, size.height / 2)));
    //
    //   canvas.drawArc(
    //       Rect.fromCenter(
    //           center: Offset(side / 2, side), width: side, height: side),
    //       math.pi,
    //       math.pi / 2,
    //       false,
    //       paint1);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
