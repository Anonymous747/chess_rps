import 'package:chess_rps/common/enum.dart';
import 'package:chess_rps/common/logger.dart';
import 'package:chess_rps/common/palette.dart';
import 'package:chess_rps/presentation/mediator/game_mode_mediator.dart';
import 'package:chess_rps/presentation/utils/app_router.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AIDifficultyLevel {
  final String name;
  final String description;
  final int skillLevel;
  final IconData icon;
  final Color color;

  const AIDifficultyLevel({
    required this.name,
    required this.description,
    required this.skillLevel,
    required this.icon,
    required this.color,
  });
}

class AIDifficultySelector extends StatefulWidget {
  static const routeName = "aiDifficultySelector";

  const AIDifficultySelector({Key? key}) : super(key: key);

  @override
  State<AIDifficultySelector> createState() => _AIDifficultySelectorState();
}

class _AIDifficultySelectorState extends State<AIDifficultySelector> {
  static const List<AIDifficultyLevel> difficultyLevels = [
    AIDifficultyLevel(
      name: 'Beginner',
      description: 'Perfect for learning the basics',
      skillLevel: 5,
      icon: Icons.sentiment_very_satisfied,
      color: Palette.success,
    ),
    AIDifficultyLevel(
      name: 'Easy',
      description: 'A gentle challenge',
      skillLevel: 10,
      icon: Icons.sentiment_satisfied,
      color: Palette.info,
    ),
    AIDifficultyLevel(
      name: 'Medium',
      description: 'A balanced opponent',
      skillLevel: 15,
      icon: Icons.sentiment_neutral,
      color: Palette.accent,
    ),
    AIDifficultyLevel(
      name: 'Hard',
      description: 'A tough challenge',
      skillLevel: 18,
      icon: Icons.sentiment_dissatisfied,
      color: Palette.warning,
    ),
    AIDifficultyLevel(
      name: 'Expert',
      description: 'Maximum difficulty',
      skillLevel: 20,
      icon: Icons.sentiment_very_dissatisfied,
      color: Palette.error,
    ),
  ];

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
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header with back button at the top
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Palette.backgroundTertiary,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Palette.glassBorder,
                          width: 1,
                        ),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back, color: Palette.textPrimary),
                        onPressed: () => context.pop(),
                      ),
                    ),
                  ],
                ),
              ),
              // Centered content
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // App Title with modern card design
                        Container(
                          padding: const EdgeInsets.all(32),
                          decoration: BoxDecoration(
                            color: Palette.backgroundTertiary,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: Palette.glassBorder,
                              width: 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Palette.accent.withValues(alpha: 0.1),
                                blurRadius: 20,
                                spreadRadius: 0,
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: Palette.accent.withValues(alpha: 0.1),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Palette.accent.withValues(alpha: 0.3),
                                    width: 2,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.smart_toy,
                                  size: 64,
                                  color: Palette.accent,
                                ),
                              ),
                              const SizedBox(height: 24),
                              const Text(
                                'Select Difficulty',
                                style: TextStyle(
                                  fontSize: 36,
                                  fontWeight: FontWeight.bold,
                                  color: Palette.textPrimary,
                                  letterSpacing: 1.5,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Choose the AI difficulty level',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Palette.textSecondary,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 48),
                        // Difficulty Buttons
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Column(
                            children: difficultyLevels.map((level) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: _buildDifficultyButton(
                                  context,
                                  level: level,
                                  onPressed: () {
                                    AppLogger.info(
                                      'User selected AI difficulty: ${level.name} (skill level: ${level.skillLevel})',
                                      tag: 'AIDifficultySelector',
                                    );
                                    GameModesMediator.setAIDifficulty(level.skillLevel);
                                    GameModesMediator.changeOpponentMode(OpponentMode.ai);
                                    context.push(AppRoutes.chess);
                                  },
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDifficultyButton(
    BuildContext context, {
    required AIDifficultyLevel level,
    required VoidCallback onPressed,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: level.color.withValues(alpha: 0.3),
            blurRadius: 20,
            spreadRadius: 0,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: Palette.backgroundElevated,
              border: Border.all(
                color: level.color.withValues(alpha: 0.5),
                width: 2,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: level.color.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    level.icon,
                    size: 28,
                    color: level.color,
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        level.name,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Palette.textPrimary,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        level.description,
                        style: TextStyle(
                          fontSize: 14,
                          color: Palette.textSecondary,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 18,
                  color: level.color,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

