import 'dart:math' as math;
import 'package:chess_rps/common/palette.dart';
import 'package:chess_rps/presentation/controller/stats_controller.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class LevelsScreen extends HookConsumerWidget {
  static const routeName = '/levels';

  const LevelsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(statsControllerProvider);

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
              // Header
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: Icon(Icons.arrow_back, color: Palette.textSecondary),
                    ),
                    Expanded(
                      child: Text(
                        'Levels & Titles',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Palette.textPrimary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(width: 48), // Balance the back button
                  ],
                ),
              ),

              // Content
              Expanded(
                child: statsAsync.when(
                  data: (stats) {
                    final currentLevel = stats.level;
                    final totalXp = stats.experience;
                    final levelProgress = stats.levelProgress;

                    return SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Current Level Card
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Palette.purpleAccent,
                                  Palette.purpleAccentDark,
                                ],
                              ),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Palette.purpleAccent.withValues(alpha: 0.3),
                                  blurRadius: 20,
                                  spreadRadius: 0,
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                Text(
                                  'Current Level',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Palette.textPrimary.withValues(alpha: 0.8),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  stats.levelName ?? 'Novice',
                                  style: TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    color: Palette.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Level $currentLevel',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Palette.textPrimary.withValues(alpha: 0.8),
                                  ),
                                ),
                                if (levelProgress != null) ...[
                                  const SizedBox(height: 16),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        '${levelProgress.currentLevelXp} / ${levelProgress.xpForNextLevel} XP',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Palette.textPrimary.withValues(alpha: 0.8),
                                        ),
                                      ),
                                      Text(
                                        '${levelProgress.progressPercentage.toStringAsFixed(1)}%',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Palette.textPrimary.withValues(alpha: 0.8),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(4),
                                    child: LinearProgressIndicator(
                                      value: levelProgress.progressPercentage / 100,
                                      minHeight: 8,
                                      backgroundColor: Colors.white.withValues(alpha: 0.2),
                                      valueColor: AlwaysStoppedAnimation<Color>(Palette.textPrimary),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),

                          // All Levels List
                          Text(
                            'All Levels',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Palette.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 16),
                          ..._buildAllLevelsList(currentLevel, totalXp),
                          const SizedBox(height: 100),
                        ],
                      ),
                    );
                  },
                  loading: () => Center(
                    child: Padding(
                      padding: const EdgeInsets.all(40),
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Palette.purpleAccent),
                      ),
                    ),
                  ),
                  error: (error, stack) => Center(
                    child: Text(
                      'Failed to load levels',
                      style: TextStyle(color: Palette.error),
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

  List<Widget> _buildAllLevelsList(int currentLevel, int totalXp) {
    // Level names from the backend level system
    final levelNames = {
      0: "Novice",
      1: "Beginner",
      2: "Apprentice",
      3: "Intermediate",
      4: "Advanced",
      5: "Expert",
      6: "Master",
      7: "Grandmaster",
      8: "International Master",
      9: "World Champion",
      10: "Legend",
      11: "Mythic",
      12: "Transcendent",
      13: "Divine",
      14: "Immortal",
    };

    // Calculate total XP required to reach a level (matches backend formula)
    // Formula: BASE_XP * (XP_MULTIPLIER ^ (level - 1))
    int calculateTotalXpForLevel(int level) {
      if (level <= 0) return 0;
      const baseXp = 100;
      const multiplier = 2.5;
      // Total XP = BASE_XP * (multiplier ^ (level - 1))
      return (baseXp * math.pow(multiplier, level - 1)).round();
    }

    return levelNames.entries.map((entry) {
      final level = entry.key;
      final levelName = entry.value;
      final xpRequired = calculateTotalXpForLevel(level);
      final isUnlocked = level <= currentLevel;
      final isCurrent = level == currentLevel;
      
      // Calculate progress for locked levels
      double progress = 0.0;
      int xpNeeded = 0;
      if (isUnlocked) {
        progress = 1.0;
      } else if (level > 0) {
        final previousLevelXp = level > 1 ? calculateTotalXpForLevel(level - 1) : 0;
        final xpForThisLevel = xpRequired - previousLevelXp;
        final xpInThisLevel = (totalXp - previousLevelXp).clamp(0, xpForThisLevel);
        progress = xpForThisLevel > 0 ? (xpInThisLevel / xpForThisLevel).clamp(0.0, 1.0) : 0.0;
        xpNeeded = xpRequired - totalXp;
      }

      return Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isCurrent
              ? Palette.purpleAccent.withValues(alpha: 0.2)
              : Palette.backgroundTertiary,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isCurrent
                ? Palette.purpleAccent
                : isUnlocked
                    ? Palette.success.withValues(alpha: 0.3)
                    : Palette.glassBorder,
            width: isCurrent ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            // Level Badge
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                gradient: isUnlocked
                    ? LinearGradient(
                        colors: isCurrent
                            ? [Palette.purpleAccent, Palette.purpleAccentDark]
                            : [Palette.success, Palette.success.withValues(alpha: 0.7)],
                      )
                    : null,
                color: isUnlocked ? null : Palette.backgroundSecondary,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isUnlocked
                      ? Colors.transparent
                      : Palette.glassBorder,
                  width: 2,
                ),
              ),
              child: Center(
                child: isUnlocked
                    ? Icon(
                        isCurrent ? Icons.star : Icons.check,
                        color: Palette.textPrimary,
                        size: 24,
                      )
                    : Icon(
                        Icons.lock,
                        color: Palette.textSecondary,
                        size: 20,
                      ),
              ),
            ),
            const SizedBox(width: 16),

            // Level Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        levelName,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isUnlocked
                              ? Palette.textPrimary
                              : Palette.textSecondary,
                        ),
                      ),
                      if (isCurrent) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Palette.purpleAccent,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'CURRENT',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Palette.textPrimary,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Level $level • ${xpRequired.toStringAsFixed(0)} XP',
                    style: TextStyle(
                      fontSize: 12,
                      color: Palette.textSecondary,
                    ),
                  ),
                  if (!isUnlocked && level > 0 && xpNeeded > 0) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: progress,
                              minHeight: 4,
                              backgroundColor: Palette.backgroundSecondary,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Palette.purpleAccent,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${(progress * 100).toStringAsFixed(1)}%',
                          style: TextStyle(
                            fontSize: 10,
                            color: Palette.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$xpNeeded XP to unlock',
                      style: TextStyle(
                        fontSize: 10,
                        color: Palette.textTertiary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      );
    }).toList();
  }
}
