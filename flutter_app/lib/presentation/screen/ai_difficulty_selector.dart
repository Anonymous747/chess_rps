import 'package:chess_rps/common/enum.dart';
import 'package:chess_rps/common/logger.dart';
import 'package:chess_rps/common/palette.dart';
import 'package:chess_rps/presentation/mediator/game_mode_mediator.dart';
import 'package:chess_rps/presentation/screen/play_flow_screen.dart';
import 'package:chess_rps/presentation/utils/app_router.dart';
import 'package:chess_rps/presentation/widget/dashboard_navigation_menu.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

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

class AIDifficultySelector extends ConsumerStatefulWidget {
  static const routeName = "aiDifficultySelector";

  const AIDifficultySelector({Key? key}) : super(key: key);

  @override
  ConsumerState<AIDifficultySelector> createState() => _AIDifficultySelectorState();
}

class _AIDifficultySelectorState extends ConsumerState<AIDifficultySelector> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: const DashboardNavigationMenu(currentIndexOverride: 2),
      body: AIDifficultySelectorContent(),
    );
  }
}

/// Content widget for AI difficulty selector (without Scaffold)
/// Can be used standalone or within PlayFlowScreen
class AIDifficultySelectorContent extends ConsumerWidget {
  const AIDifficultySelectorContent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
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
            // Header with back button
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
                      onPressed: () {
                        // Check if we're in play flow screen, if so use state, otherwise pop
                        try {
                          ref.read(playFlowStateProvider.notifier).goBackToOpponentSelector();
                        } catch (e) {
                          if (context.mounted) {
                            context.pop();
                          }
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
            // Centered content
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(minHeight: constraints.maxHeight),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // App Title with modern card design
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
                            margin: const EdgeInsets.symmetric(horizontal: 14),
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
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(16),
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
                                    size: 48,
                                    color: Palette.accent,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                const Text(
                                  'Select Difficulty',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    color: Palette.textPrimary,
                                    letterSpacing: 1.0,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16),
                                  child: Text(
                                    'Choose the AI difficulty level',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Palette.textSecondary,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 32),
                          // Difficulty Buttons - compact design
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Column(
                              children: _difficultyLevels.asMap().entries.map((entry) {
                                final index = entry.key;
                                final level = entry.value;
                                return Padding(
                                  padding: EdgeInsets.only(
                                      bottom: index < _difficultyLevels.length - 1 ? 12 : 0),
                                  child: _buildDifficultyButton(
                                    context,
                                    ref,
                                    level: level,
                                    onPressed: () {
                                      AppLogger.info(
                                        'User selected AI difficulty: ${level.name} (skill level: ${level.skillLevel})',
                                        tag: 'AIDifficultySelector',
                                      );
                                      GameModesMediator.setAIDifficulty(level.skillLevel);
                                      GameModesMediator.changeOpponentMode(OpponentMode.ai);
                                      if (context.mounted) {
                                        context.push(AppRoutes.chess);
                                      }
                                    },
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  static const List<AIDifficultyLevel> _difficultyLevels = [
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

  Widget _buildDifficultyButton(
    BuildContext context,
    WidgetRef ref, {
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
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
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
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: level.color.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    level.icon,
                    size: 24,
                    color: level.color,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        level.name,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Palette.textPrimary,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        level.description,
                        style: TextStyle(
                          fontSize: 12,
                          color: Palette.textSecondary,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
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
