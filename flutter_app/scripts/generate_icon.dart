import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

/// Script to generate app icons from the chess icon widget
/// Run with: flutter run -d linux/windows/macos scripts/generate_icon.dart
/// Or use: dart run flutter_app/scripts/generate_icon.dart

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  final sizes = [
    48, 72, 96, 144, 192, 512,
    // Android sizes
    48, 72, 96, 144, 192, 512,
    // iOS sizes
    1024,
  ];
  
  print('Generating chess icons...');
  
  for (final size in sizes) {
    final image = await _generateIcon(size);
    final file = File('flutter_app/assets/images/app_icon_$size.png');
    await file.create(recursive: true);
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    await file.writeAsBytes(bytes!.buffer.asUint8List());
    print('Generated: ${file.path}');
  }
  
  print('Done! Icons generated in flutter_app/assets/images/');
}

Future<ui.Image> _generateIcon(int size) async {
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);
  final paint = Paint();
  
  // Background circle with gradient
  final center = Offset(size / 2, size / 2);
  final radius = size / 2 - size * 0.05;
  
  // Background
  final backgroundGradient = RadialGradient(
    colors: [
      const Color(0xFF1E2742),
      const Color(0xFF141B2D),
      const Color(0xFF0A0E27),
    ],
    stops: const [0.0, 0.7, 1.0],
  );
  paint.shader = backgroundGradient.createShader(
    Rect.fromCircle(center: center, radius: radius),
  );
  canvas.drawCircle(center, radius, paint);
  
  // Border
  paint.shader = null;
  paint.color = const Color(0x30FFFFFF);
  paint.style = PaintingStyle.stroke;
  paint.strokeWidth = size * 0.02;
  canvas.drawCircle(center, radius, paint);
  
  // Draw chess board pattern (4x4 squares)
  final squareSize = radius * 0.6 / 4;
  final boardOffset = Offset(
    center.dx - squareSize * 2,
    center.dy - squareSize * 2,
  );
  
  for (int row = 0; row < 4; row++) {
    for (int col = 0; col < 4; col++) {
      final isLight = (row + col) % 2 == 0;
      paint.style = PaintingStyle.fill;
      paint.color = isLight
          ? const Color(0xFF00D4FF).withValues(alpha: 0.2)
          : const Color(0xFF7C3AED).withValues(alpha: 0.3);
      
      final squareRect = Rect.fromLTWH(
        boardOffset.dx + col * squareSize,
        boardOffset.dy + row * squareSize,
        squareSize,
        squareSize,
      );
      canvas.drawRect(squareRect, paint);
    }
  }
  
  // Draw chess pieces (king and queen)
  final pieceSize = squareSize * 0.8;
  
  // King
  _drawKing(canvas, Offset(
    boardOffset.dx + squareSize * 0.5,
    boardOffset.dy + squareSize * 1.5,
  ), pieceSize);
  
  // Queen
  _drawQueen(canvas, Offset(
    boardOffset.dx + squareSize * 2.5,
    boardOffset.dy + squareSize * 1.5,
  ), pieceSize);
  
  // Accent arcs
  paint.color = const Color(0xFF00D4FF).withValues(alpha: 0.6);
  paint.style = PaintingStyle.stroke;
  paint.strokeWidth = size * 0.015;
  
  // Top arc
  canvas.drawArc(
    Rect.fromCircle(center: center, radius: radius - size * 0.05),
    -0.3 * 3.14159,
    0.6 * 3.14159,
    false,
    paint,
  );
  
  // Bottom arc
  canvas.drawArc(
    Rect.fromCircle(center: center, radius: radius - size * 0.05),
    0.7 * 3.14159,
    0.6 * 3.14159,
    false,
    paint,
  );
  
  final picture = recorder.endRecording();
  return await picture.toImage(size, size);
}

void _drawKing(Canvas canvas, Offset center, double size) {
  final paint = Paint()
    ..color = const Color(0xFF00D4FF).withValues(alpha: 0.9)
    ..style = PaintingStyle.fill;
  
  // Base
  canvas.drawRect(
    Rect.fromCenter(
      center: Offset(center.dx, center.dy + size * 0.3),
      width: size * 0.4,
      height: size * 0.2,
    ),
    paint,
  );
  
  // Body
  canvas.drawRect(
    Rect.fromCenter(
      center: Offset(center.dx, center.dy),
      width: size * 0.35,
      height: size * 0.4,
    ),
    paint,
  );
  
  // Cross
  canvas.drawRect(
    Rect.fromCenter(
      center: Offset(center.dx, center.dy - size * 0.35),
      width: size * 0.15,
      height: size * 0.25,
    ),
    paint,
  );
  canvas.drawRect(
    Rect.fromCenter(
      center: Offset(center.dx, center.dy - size * 0.4),
      width: size * 0.25,
      height: size * 0.1,
    ),
    paint,
  );
}

void _drawQueen(Canvas canvas, Offset center, double size) {
  final paint = Paint()
    ..color = const Color(0xFF7C3AED).withValues(alpha: 0.9)
    ..style = PaintingStyle.fill;
  
  // Base
  canvas.drawRect(
    Rect.fromCenter(
      center: Offset(center.dx, center.dy + size * 0.3),
      width: size * 0.4,
      height: size * 0.2,
    ),
    paint,
  );
  
  // Body
  canvas.drawRect(
    Rect.fromCenter(
      center: Offset(center.dx, center.dy),
      width: size * 0.35,
      height: size * 0.4,
    ),
    paint,
  );
  
  // Crown
  final crownPaint = Paint()
    ..color = const Color(0xFF9F7AEA).withValues(alpha: 0.9)
    ..style = PaintingStyle.fill;
  
  for (int i = 0; i < 3; i++) {
    final x = center.dx + (i - 1) * size * 0.15;
    final path = Path()
      ..moveTo(x, center.dy - size * 0.25)
      ..lineTo(x - size * 0.06, center.dy - size * 0.4)
      ..lineTo(x + size * 0.06, center.dy - size * 0.4)
      ..close();
    canvas.drawPath(path, crownPaint);
  }
}

