import 'dart:math' as math;
import 'package:chess_rps/common/palette.dart';
import 'package:flutter/material.dart';

/// Beautiful app loading screen with animated chess icon
class AppLoadingScreen extends StatefulWidget {
  const AppLoadingScreen({Key? key}) : super(key: key);

  @override
  State<AppLoadingScreen> createState() => _AppLoadingScreenState();
}

class _AppLoadingScreenState extends State<AppLoadingScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _glowController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();

    // Pulse animation for the icon
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    // Glow animation
    _glowController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat();

    _pulseAnimation = Tween<double>(
      begin: 0.95,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _glowAnimation = Tween<double>(
      begin: 0.3,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _glowController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Palette.background,
              Palette.backgroundSecondary,
              Palette.backgroundTertiary,
            ],
            stops: const [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Animated chess icon with dark background
                AnimatedBuilder(
                  animation: Listenable.merge([
                    _pulseAnimation,
                    _glowAnimation,
                  ]),
                  builder: (context, child) {
                    return Container(
                      width: 180,
                      height: 180,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Palette.background,
                        boxShadow: [
                          BoxShadow(
                            color: Palette.accent.withValues(
                              alpha: _glowAnimation.value * 0.6,
                            ),
                            blurRadius: 40,
                            spreadRadius: 10,
                          ),
                          BoxShadow(
                            color: Palette.purpleAccent.withValues(
                              alpha: _glowAnimation.value * 0.4,
                            ),
                            blurRadius: 30,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: Center(
                        child: Transform.scale(
                          scale: _pulseAnimation.value,
                          child: CustomPaint(
                            painter: ChessIconPainter(
                              glowIntensity: _glowAnimation.value,
                            ),
                            size: const Size(140, 140),
                          ),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 48),
                // App name
                Text(
                  'Chess RPS',
                  style: TextStyle(
                    color: Palette.textPrimary,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                    shadows: [
                      Shadow(
                        color: Palette.accent.withValues(alpha: 0.5),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Loading indicator with gradient
                Container(
                  width: 200,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Palette.backgroundTertiary,
                    borderRadius: BorderRadius.circular(2),
                  ),
                  child: Stack(
                    children: [
                      AnimatedBuilder(
                        animation: _pulseController,
                        builder: (context, child) {
                          return Positioned(
                            left: (_pulseController.value % 1.0) * 170,
                            child: Container(
                              width: 30,
                              height: 4,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Palette.accent,
                                    Palette.purpleAccent,
                                    Palette.accent,
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(2),
                                boxShadow: [
                                  BoxShadow(
                                    color: Palette.accent.withValues(alpha: 0.8),
                                    blurRadius: 8,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                // Loading dots
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(3, (index) {
                    return AnimatedBuilder(
                      animation: _pulseController,
                      builder: (context, child) {
                        final delay = index * 0.3;
                        final animationValue = (_pulseController.value + delay) % 1.0;
                        final opacity = (animationValue < 0.5)
                            ? animationValue * 2
                            : 2 - (animationValue * 2);
                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 6),
                          width: 14,
                          height: 14,
                          decoration: BoxDecoration(
                            color: Palette.accent.withValues(alpha: opacity),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Palette.accent.withValues(
                                  alpha: opacity * 0.6,
                                ),
                                blurRadius: 10,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  }),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Custom painter for the chess icon
class ChessIconPainter extends CustomPainter {
  final double glowIntensity;

  ChessIconPainter({this.glowIntensity = 1.0});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 10;

    // Outer glow circle
    final glowPaint = Paint()
      ..color = Palette.accent.withValues(alpha: glowIntensity * 0.3)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius + 5, glowPaint);

    // Background circle with gradient effect
    final backgroundGradient = RadialGradient(
      colors: [
        Palette.backgroundTertiary,
        Palette.backgroundSecondary,
        Palette.background,
      ],
      stops: const [0.0, 0.7, 1.0],
    );
    final backgroundPaint = Paint()
      ..shader = backgroundGradient.createShader(
        Rect.fromCircle(center: center, radius: radius),
      );
    canvas.drawCircle(center, radius, backgroundPaint);

    // Border with glassmorphism effect
    final borderPaint = Paint()
      ..color = Palette.glassBorder
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawCircle(center, radius, borderPaint);

    // Draw chess board pattern (4x4 squares)
    final squareSize = radius * 0.6 / 4;
    final boardOffset = Offset(
      center.dx - squareSize * 2,
      center.dy - squareSize * 2,
    );

    for (int row = 0; row < 4; row++) {
      for (int col = 0; col < 4; col++) {
        final isLight = (row + col) % 2 == 0;
        final squarePaint = Paint()
          ..color = isLight
              ? Palette.accent.withValues(alpha: 0.2)
              : Palette.purpleAccent.withValues(alpha: 0.3)
          ..style = PaintingStyle.fill;

        final squareRect = Rect.fromLTWH(
          boardOffset.dx + col * squareSize,
          boardOffset.dy + row * squareSize,
          squareSize,
          squareSize,
        );
        canvas.drawRect(squareRect, squarePaint);
      }
    }

    // Draw chess pieces (king and queen silhouettes)
    final pieceSize = squareSize * 0.8;
    
    // King on left
    final kingCenter = Offset(
      boardOffset.dx + squareSize * 0.5,
      boardOffset.dy + squareSize * 1.5,
    );
    _drawKing(canvas, kingCenter, pieceSize);

    // Queen on right
    final queenCenter = Offset(
      boardOffset.dx + squareSize * 2.5,
      boardOffset.dy + squareSize * 1.5,
    );
    _drawQueen(canvas, queenCenter, pieceSize);

    // Accent lines
    final accentPaint = Paint()
      ..color = Palette.accent.withValues(alpha: glowIntensity * 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    
    // Top accent arc
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - 5),
      -math.pi * 0.3,
      math.pi * 0.6,
      false,
      accentPaint,
    );

    // Bottom accent arc
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - 5),
      math.pi * 0.7,
      math.pi * 0.6,
      false,
      accentPaint,
    );
  }

  void _drawKing(Canvas canvas, Offset center, double size) {
    final paint = Paint()
      ..color = Palette.accent.withValues(alpha: 0.9)
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

    // Cross on top
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
      ..color = Palette.purpleAccent.withValues(alpha: 0.9)
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

    // Crown (3 points)
    final crownPaint = Paint()
      ..color = Palette.purpleAccentLight.withValues(alpha: 0.9)
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

  @override
  bool shouldRepaint(covariant ChessIconPainter oldDelegate) {
    return oldDelegate.glowIntensity != glowIntensity;
  }
}

