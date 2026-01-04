import 'package:chess_rps/common/logger.dart';
import 'package:chess_rps/common/palette.dart';
import 'package:chess_rps/data/service/collection/collection_service.dart';
import 'package:chess_rps/data/service/friends/friends_service.dart';
import 'package:chess_rps/data/service/stats/stats_service.dart';
import 'package:chess_rps/l10n/app_localizations.dart';
import 'package:chess_rps/presentation/controller/auth_controller.dart';
import 'package:chess_rps/presentation/controller/collection_controller.dart';
import 'package:chess_rps/presentation/controller/friends_controller.dart';
import 'package:chess_rps/presentation/controller/stats_controller.dart';
import 'package:chess_rps/presentation/utils/app_router.dart';
import 'package:chess_rps/presentation/utils/avatar_utils.dart';
import 'package:chess_rps/presentation/widget/skeleton_loader.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class ProfileScreen extends HookConsumerWidget {
  static const routeName = '/profile';

  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final statsAsync = ref.watch(statsControllerProvider);
    final userCollectionAsync = ref.watch(userCollectionControllerProvider);
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
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: Icon(Icons.arrow_back, color: Palette.textSecondary),
                    ),
                    Text(
                      l10n.playerProfile,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Palette.textSecondary,
                      ),
                    ),
                    IconButton(
                      onPressed: () async {
                        // Logout and navigate to login screen
                        await ref.read(authControllerProvider.notifier).logout();
                        if (context.mounted) {
                          context.go(AppRoutes.login);
                        }
                      },
                      icon: Icon(Icons.logout, color: Palette.error),
                      tooltip: l10n.logout,
                      style: IconButton.styleFrom(
                        backgroundColor: Palette.error.withValues(alpha: 0.1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: Palette.error.withValues(alpha: 0.3)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      // Profile Header
                      _buildProfileHeader(context, ref, statsAsync, userCollectionAsync, l10n),
                      const SizedBox(height: 24),

                      // Stats Grid
                      _buildStatsGrid(context, ref, statsAsync, l10n),
                      const SizedBox(height: 24),

                      // Performance Chart
                      _buildPerformanceSection(statsAsync, l10n),
                      const SizedBox(height: 24),

                      // Achievements
                      _buildAchievementsSection(l10n),
                      const SizedBox(height: 24),

                      // Showcase
                      _buildShowcaseSection(l10n),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<UserStats> statsAsync,
    AsyncValue<List<UserCollectionItem>> userCollectionAsync,
    AppLocalizations l10n,
  ) {
    return statsAsync.when(
      data: (stats) {
        final levelProgress = stats.levelProgress;
        final progressValue = levelProgress != null && levelProgress.xpForNextLevel > 0
            ? levelProgress.currentLevelXp / levelProgress.xpForNextLevel
            : 0.0;
        final levelName = stats.levelName ?? 'Novice';
        final level = stats.level;
        final xpForNext = levelProgress?.xpForNextLevel ?? 100;
        final currentXp = levelProgress?.currentLevelXp ?? 0;

        // Get equipped avatar
        UserCollectionItem? equippedAvatar;
        try {
          equippedAvatar = userCollectionAsync.valueOrNull?.firstWhere(
            (uc) => uc.isEquipped && uc.item.category == CollectionCategory.AVATARS,
          );
        } catch (e) {
          // No equipped avatar found
          equippedAvatar = null;
        }
        final avatarUrl = equippedAvatar != null
            ? AvatarUtils.getAvatarImageUrl(equippedAvatar.item.iconName)
            : AvatarUtils.getDefaultAvatarUrl();

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Palette.purpleAccent.withValues(alpha: 0.15),
                blurRadius: 25,
                spreadRadius: 0,
                offset: const Offset(0, 6),
              ),
              BoxShadow(
                color: Palette.black.withValues(alpha: 0.1),
                blurRadius: 15,
                spreadRadius: 0,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 112,
                    height: 112,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Palette.purpleAccent.withValues(alpha: 0.3),
                        width: 2,
                        style: BorderStyle.solid,
                      ),
                    ),
                  child: CircularProgressIndicator(
                    value: progressValue.clamp(0.0, 1.0),
                    strokeWidth: 2,
                    color: Palette.purpleAccent,
                    backgroundColor: Colors.transparent,
                  ),
                ),
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Palette.glassBorder, width: 2),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    // Navigate to collection screen with avatars tab selected
                    context.push('${AppRoutes.collection}?tab=avatars');
                  },
                  child: Container(
                    width: 88,
                    height: 88,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Palette.purpleAccent.withValues(alpha: 0.4),
                          blurRadius: 25,
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        ClipOval(
                          child: Image.network(
                            avatarUrl,
                            width: 88,
                            height: 88,
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return SkeletonAvatar(size: 88);
                            },
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                width: 88,
                                height: 88,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [Palette.purpleAccent, Palette.purpleAccentDark],
                                  ),
                                ),
                                child: Icon(Icons.person, color: Palette.textPrimary, size: 48),
                              );
                            },
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Palette.purpleAccent,
                              shape: BoxShape.circle,
                              border: Border.all(color: Palette.background, width: 2),
                            ),
                            child: Icon(
                              Icons.edit,
                              color: Palette.textPrimary,
                              size: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Palette.background,
                      shape: BoxShape.circle,
                    ),
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: Palette.purpleAccent,
                        shape: BoxShape.circle,
                        border: Border.all(color: Palette.background, width: 2),
                      ),
                      child: Center(
                        child: Text(
                          '$level',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Palette.textPrimary,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Profile Name with Edit Button
            _buildProfileNameSection(context, ref, l10n),
          ],
        ),
      );
      },
      loading: () => Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Palette.accent),
          ),
        ),
      ),
      error: (error, stack) => Column(
        children: [
          Icon(Icons.error_outline, size: 64, color: Palette.error),
          const SizedBox(height: 16),
          Text(
            l10n.errorLoadingProfile,
            style: TextStyle(
              fontSize: 16,
              color: Palette.error,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(BuildContext context, WidgetRef ref, AsyncValue<UserStats> statsAsync, AppLocalizations l10n) {
    return statsAsync.when(
      data: (stats) {
        final ratingChange = stats.ratingChange;
        final ratingChangeText = ratingChange >= 0 ? '+$ratingChange' : '$ratingChange';
        final ratingChangeColor = ratingChange >= 0 ? Palette.success : Palette.error;

        final winRateText = stats.totalGames > 0 ? '${stats.winRate.toStringAsFixed(1)}%' : '0%';
        final totalGamesText = '${stats.totalGames} Games';

        // Win streak can't be negative - show 0 if current streak is negative
        final winStreak = stats.currentStreak > 0 ? stats.currentStreak : 0;
        final streakText = '$winStreak';

        return Row(
          children: [
            Expanded(
              child: _buildStatCard(
                l10n.rating,
                '${stats.rating}',
                ratingChangeText,
                ratingChangeColor,
                Icons.trending_up,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                l10n.winRate,
                winRateText,
                totalGamesText,
                Palette.accent,
                null,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                l10n.streak,
                streakText,
                l10n.best('${stats.bestStreak}'),
                Palette.purpleAccent,
                Icons.local_fire_department,
              ),
            ),
          ],
        );
      },
      loading: () => Row(
        children: [
          Expanded(child: SkeletonCard(height: 100)),
          const SizedBox(width: 12),
          Expanded(child: SkeletonCard(height: 100)),
          const SizedBox(width: 12),
          Expanded(child: SkeletonCard(height: 100)),
        ],
      ),
      error: (error, stack) => Row(
        children: [
          Expanded(child: _buildStatCard(l10n.rating, 'Error', '', Palette.error, null)),
          const SizedBox(width: 12),
          Expanded(child: _buildStatCard(l10n.winRate, 'Error', '', Palette.error, null)),
          const SizedBox(width: 12),
          Expanded(child: _buildStatCard(l10n.streak, 'Error', '', Palette.error, null)),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, String subtitle, Color color, IconData? icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Palette.backgroundTertiary,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Palette.glassBorder),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.25),
            blurRadius: 18,
            spreadRadius: 0,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Palette.black.withValues(alpha: 0.15),
            blurRadius: 12,
            spreadRadius: 0,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: Palette.textTertiary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 10, color: color),
                const SizedBox(width: 4),
              ],
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 10,
                  color: color.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceSection(AsyncValue<UserStats> statsAsync, AppLocalizations l10n) {
    final selectedPeriod = useState<String>('Weekly'); // Default to Weekly
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              l10n.performance,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Palette.textPrimary,
              ),
            ),
            Row(
              children: [
                _buildTimeFilter(
                  l10n.weekly,
                  selectedPeriod.value == 'Weekly',
                  () => selectedPeriod.value = 'Weekly',
                ),
                const SizedBox(width: 8),
                _buildTimeFilter(
                  l10n.monthly,
                  selectedPeriod.value == 'Monthly',
                  () => selectedPeriod.value = 'Monthly',
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          height: 180,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Palette.backgroundTertiary,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Palette.glassBorder),
            boxShadow: [
              BoxShadow(
                color: Palette.purpleAccent.withValues(alpha: 0.15),
                blurRadius: 25,
                spreadRadius: 0,
                offset: const Offset(0, 6),
              ),
              BoxShadow(
                color: Palette.black.withValues(alpha: 0.1),
                blurRadius: 15,
                spreadRadius: 0,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: statsAsync.when(
            data: (stats) {
              final history = stats.performanceHistory;
              if (history != null && history.isNotEmpty) {
                // Filter history based on selected period
                final now = DateTime.now();
                final filteredHistory = history.where((item) {
                  final daysDiff = now.difference(item.createdAt).inDays;
                  if (selectedPeriod.value == 'Weekly') {
                    return daysDiff <= 7;
                  } else {
                    return daysDiff <= 30;
                  }
                }).toList();
                
                if (filteredHistory.isEmpty) {
                  return Center(
                    child: Text(
                      l10n.noPerformanceData(selectedPeriod.value.toLowerCase()),
                      style: TextStyle(
                        color: Palette.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                  );
                }
                
                return AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder: (Widget child, Animation<double> animation) {
                    return FadeTransition(
                      opacity: animation,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0.0, 0.1),
                          end: Offset.zero,
                        ).animate(CurvedAnimation(
                          parent: animation,
                          curve: Curves.easeOut,
                        )),
                        child: child,
                      ),
                    );
                  },
                  child: CustomPaint(
                    key: ValueKey('${selectedPeriod.value}_${filteredHistory.length}'),
                    painter: _PerformanceChartPainter(filteredHistory, selectedPeriod.value),
                    child: Container(),
                  ),
                );
              } else {
                return Center(
                  child: Text(
                    l10n.noPerformanceDataYet,
                    style: TextStyle(
                      color: Palette.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                );
              }
            },
            loading: () => Center(
              child: Padding(
                padding: const EdgeInsets.all(40),
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Palette.accent),
                ),
              ),
            ),
            error: (error, stack) => Center(
              child: Text(
                l10n.errorLoadingPerformance,
                style: TextStyle(
                  color: Palette.error,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTimeFilter(String label, bool isActive, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? Colors.white.withValues(alpha: 0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isActive ? Palette.accent.withValues(alpha: 0.5) : Colors.transparent,
            width: 1,
          ),
        ),
        child: AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
            color: isActive ? Palette.textPrimary : Palette.textSecondary,
          ),
          child: Text(label),
        ),
      ),
    );
  }

  Widget _buildAchievementsSection(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              l10n.achievements,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Palette.textPrimary,
              ),
            ),
            TextButton(
              onPressed: () {},
              child: Text(
                l10n.viewAll,
                style: TextStyle(color: Palette.accent),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildAchievementCard(
                  l10n.grandmasterAchievement, l10n.reach2500MMR, Icons.emoji_events, Palette.gold, true),
              const SizedBox(width: 12),
              _buildAchievementCard(
                  l10n.onFire, l10n.winStreak10, Icons.local_fire_department, Palette.error, true),
              const SizedBox(width: 12),
              _buildAchievementCard(
                  l10n.puzzleMaster, l10n.solve1000Puzzles, Icons.extension, Palette.accent, false),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAchievementCard(
    String title,
    String subtitle,
    IconData icon,
    Color color,
    bool isUnlocked,
  ) {
    return Container(
      width: 140,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Palette.backgroundTertiary,
            Palette.backgroundSecondary,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Palette.glassBorder),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: isUnlocked ? 0.25 : 0.1),
            blurRadius: 18,
            spreadRadius: 0,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Palette.black.withValues(alpha: 0.15),
            blurRadius: 12,
            spreadRadius: 0,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
              boxShadow: isUnlocked
                  ? [
                      BoxShadow(
                        color: color.withValues(alpha: 0.2),
                        blurRadius: 15,
                      ),
                    ]
                  : null,
            ),
            child: Icon(
              icon,
              color: isUnlocked ? color : Palette.textTertiary,
              size: 24,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: isUnlocked ? Palette.textPrimary : Palette.textTertiary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 10,
              color: isUnlocked ? Palette.textTertiary : Palette.textTertiary.withValues(alpha: 0.5),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildShowcaseSection(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.showcase,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Palette.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildShowcaseItem(
                  l10n.voidSpiritKnight, l10n.legendarySkin, Icons.extension, Palette.purpleAccent),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildShowcaseItem(
                  l10n.nebulaQueen, l10n.epicSkin, Icons.star, Palette.purpleAccentLight),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildShowcaseItem(String title, String subtitle, IconData icon, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: Palette.backgroundTertiary,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Palette.glassBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 128,
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.4),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Center(
              child: Icon(
                icon,
                size: 64,
                color: color,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Palette.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 10,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showAddFriendsOverlay(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final searchController = ref.read(friendsSearchControllerProvider.notifier);
    final requestsController = ref.read(friendRequestsControllerProvider.notifier);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext bottomSheetContext) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.85,
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
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
            border: Border.all(color: Palette.glassBorder),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Palette.textTertiary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      l10n.addFriends,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Palette.textPrimary,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(bottomSheetContext).pop(),
                      icon: Icon(Icons.close, color: Palette.textSecondary),
                    ),
                  ],
                ),
              ),

              // Search field
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _AddFriendsSearchField(
                  onSearchChanged: (value) {
                    if (value.length >= 3) {
                      searchController.searchUsers(value);
                    } else {
                      searchController.clearSearch();
                    }
                  },
                ),
              ),

              const SizedBox(height: 20),

              // Search results
              Expanded(
                child: Consumer(
                  builder: (context, ref, child) {
                    final searchAsync = ref.watch(friendsSearchControllerProvider);
                    final searchControllerRef = ref.read(friendsSearchControllerProvider.notifier);
                    final l10n = AppLocalizations.of(bottomSheetContext);
                    return _buildSearchResultsList(
                      bottomSheetContext,
                      ref,
                      searchAsync,
                      requestsController,
                      searchControllerRef,
                      l10n!,
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSearchResultsList(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<List<SearchUserResponse>> searchAsync,
    FriendRequestsController requestsController,
    FriendsSearchController searchController,
    AppLocalizations l10n,
  ) {
    return searchAsync.when(
      data: (results) {
        if (results.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.search, size: 64, color: Palette.textTertiary),
                const SizedBox(height: 16),
                Text(
                  l10n.searchForFriends,
                  style: TextStyle(
                    color: Palette.textSecondary,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Text(
                    l10n.enterAtLeast3Characters,
                    style: TextStyle(
                      color: Palette.textTertiary,
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: results.length,
          itemBuilder: (context, index) {
            final user = results[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Palette.backgroundTertiary,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Palette.glassBorder),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Palette.backgroundSecondary, Palette.backgroundTertiary],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Palette.glassBorder),
                      ),
                      child: Center(
                        child: Text(
                          user.phoneNumber.length >= 2
                              ? user.phoneNumber
                                  .substring(user.phoneNumber.length - 2)
                                  .toUpperCase()
                              : 'U',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Palette.textPrimary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                user.phoneNumber,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Palette.textPrimary,
                                ),
                              ),
                              if (user.rating != null) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Palette.purpleAccent.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(4),
                                    border:
                                        Border.all(color: Palette.purpleAccent.withValues(alpha: 0.2)),
                                  ),
                                  child: Text(
                                    '${user.rating}',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: Palette.purpleAccent,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            user.isFriend
                                ? l10n.alreadyFriends
                                : (user.friendshipStatus == 'pending'
                                    ? l10n.requestPending
                                    : l10n.notFriends),
                            style: TextStyle(
                              fontSize: 12,
                              color: Palette.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (!user.isFriend && user.friendshipStatus != 'pending')
                      IconButton(
                        onPressed: () async {
                          try {
                            await requestsController.sendFriendRequest(user.id);
                            if (context.mounted) {
                              final l10n = AppLocalizations.of(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(l10n != null ? l10n.friendRequestSent : 'Friend request sent'),
                                  backgroundColor: Palette.success,
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            }
                          } catch (e) {
                            if (context.mounted) {
                              final l10n = AppLocalizations.of(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(l10n != null ? l10n.failedToSendRequest(e.toString()) : 'Failed to send request: $e'),
                                  backgroundColor: Palette.error,
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            }
                          }
                        },
                        icon: Icon(Icons.person_add, color: Palette.purpleAccent),
                        style: IconButton.styleFrom(
                          backgroundColor: Palette.purpleAccent.withValues(alpha: 0.1),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                            side: BorderSide(color: Palette.purpleAccent.withValues(alpha: 0.2)),
                          ),
                        ),
                      )
                    else if (user.isFriend)
                      Icon(Icons.check_circle, color: Palette.success, size: 24)
                    else
                      Icon(Icons.hourglass_empty, color: Palette.warning, size: 24),
                  ],
                ),
              ),
            );
          },
        );
      },
      loading: () => Center(
        child: CircularProgressIndicator(color: Palette.accent),
      ),
      error: (error, stack) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Palette.error),
            const SizedBox(height: 16),
            Text(
              l10n.errorSearchingUsers,
              style: TextStyle(color: Palette.error, fontSize: 14),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => searchController.clearSearch(),
              child: Text(l10n.tryAgain),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileNameSection(BuildContext context, WidgetRef ref, AppLocalizations l10n) {
    return _ProfileNameSection(key: const ValueKey('profile_name_section'), l10n: l10n);
  }
}

// Separate HookWidget for profile name section to maintain hook consistency
class _ProfileNameSection extends HookConsumerWidget {
  final AppLocalizations l10n;
  const _ProfileNameSection({Key? key, required this.l10n}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Get username from stats (which comes from backend) as primary source
    // Fallback to auth controller if stats not available
    final statsAsync = ref.watch(statsControllerProvider);
    final authUser = ref.watch(authControllerProvider).valueOrNull;
    final profileName = statsAsync.valueOrNull?.username ?? authUser?.profileName ?? 'Player';
    // Hooks must be called in the same order every time - using consistent types
    final isEditing = useState<bool>(false);
    final nameController = useTextEditingController();
    final isLoading = useState<bool>(false);
    
    // Update controller text when profileName changes (but not when editing)
    useEffect(() {
      if (!isEditing.value) {
        nameController.text = profileName;
      }
      return null;
    }, [profileName]);

    if (isEditing.value) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Palette.backgroundTertiary,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Palette.purpleAccent.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: nameController,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Palette.textPrimary,
                ),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: l10n.enterName,
                  hintStyle: TextStyle(color: Palette.textSecondary),
                ),
                maxLength: 50,
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(width: 8),
            if (isLoading.value)
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Palette.purpleAccent,
                ),
              )
            else
              IconButton(
                onPressed: () async {
                  final newName = nameController.text.trim();
                  if (newName.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(l10n.nameCannotBeEmpty),
                        backgroundColor: Palette.error,
                      ),
                    );
                    return;
                  }

                  isLoading.value = true;
                  try {
                    await ref.read(authControllerProvider.notifier).updateProfileName(newName);
                    
                    // Invalidate leaderboard to refresh with updated name
                    // Invalidate all possible limit values that might be in use
                    ref.invalidate(leaderboardProvider(3));
                    ref.invalidate(leaderboardProvider(10));
                    ref.invalidate(leaderboardProvider(50));
                    
                    isEditing.value = false;
                    AppLogger.info('Profile name updated: $newName', tag: 'ProfileScreen');
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(l10n.profileNameUpdated),
                        backgroundColor: Palette.success,
                      ),
                    );
                  } catch (e) {
                    AppLogger.error('Failed to update profile name', tag: 'ProfileScreen', error: e);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(l10n.failedToUpdateProfileName),
                        backgroundColor: Palette.error,
                      ),
                    );
                  } finally {
                    isLoading.value = false;
                  }
                },
                icon: Icon(Icons.check, color: Palette.success, size: 24),
                padding: EdgeInsets.zero,
                constraints: BoxConstraints(),
              ),
            const SizedBox(width: 4),
            IconButton(
              onPressed: () {
                nameController.text = profileName;
                isEditing.value = false;
              },
              icon: Icon(Icons.close, color: Palette.error, size: 24),
              padding: EdgeInsets.zero,
              constraints: BoxConstraints(),
            ),
          ],
        ),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          profileName,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Palette.textPrimary,
          ),
        ),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: () {
            nameController.text = profileName;
            isEditing.value = true;
          },
          child: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Palette.backgroundTertiary,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Palette.glassBorder),
            ),
            child: Icon(
              Icons.edit,
              size: 16,
              color: Palette.purpleAccent,
            ),
          ),
        ),
      ],
    );
  }
}

class _PerformanceChartPainter extends CustomPainter {
  final List<PerformanceHistoryItem> history;
  final String period;

  _PerformanceChartPainter(this.history, this.period);

  @override
  void paint(Canvas canvas, Size size) {
    if (history.isEmpty) return;

    // Reserve space at bottom for date labels
    const dateLabelHeight = 20.0;
    final chartHeight = size.height - dateLabelHeight;

    // Find min and max rating for scaling
    final ratings = history.map((h) => h.rating).toList();
    final minRating = ratings.reduce((a, b) => a < b ? a : b);
    final maxRating = ratings.reduce((a, b) => a > b ? a : b);
    final ratingRange = maxRating - minRating;
    final padding = ratingRange * 0.1; // 10% padding

    final paint = Paint()
      ..color = Palette.purpleAccent
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    final points = <Offset>[];

    // Generate points from history
    for (int i = 0; i < history.length; i++) {
      final normalizedRating =
          (history[i].rating - minRating + padding) / (ratingRange + padding * 2);
      final x = size.width * (i / (history.length - 1).clamp(1, double.infinity));
      final y = chartHeight * (1 - normalizedRating); // Invert Y axis, use chartHeight
      points.add(Offset(x, y));
    }

    if (points.isEmpty) return;

    path.moveTo(points[0].dx, points[0].dy);
    for (int i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx, points[i].dy);
    }

    canvas.drawPath(path, paint);

    // Fill
    final fillPath = Path.from(path)
      ..lineTo(size.width, chartHeight)
      ..lineTo(0, chartHeight)
      ..close();

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Palette.purpleAccent.withValues(alpha: 0.3),
          Palette.purpleAccent.withValues(alpha: 0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, chartHeight))
      ..style = PaintingStyle.fill;

    canvas.drawPath(fillPath, fillPaint);

    // Draw points for significant changes
    for (int i = 0; i < points.length; i++) {
      if (i > 0) {
        final prevRating = history[i - 1].rating;
        final currRating = history[i].rating;
        if ((currRating - prevRating).abs() >= 10) {
          // Significant change
          canvas.drawCircle(
              points[i],
              4,
              Paint()
                ..color = Palette.purpleAccent
                ..style = PaintingStyle.fill);
          canvas.drawCircle(
              points[i],
              4,
              Paint()
                ..color = Palette.background
                ..style = PaintingStyle.stroke
                ..strokeWidth = 2);
        }
      }
    }

    // Draw date labels (2-3 dates evenly distributed)
    final dateIndices = <int>[];
    
    if (history.length == 1) {
      dateIndices.add(0);
    } else if (history.length == 2) {
      dateIndices.add(0);
      dateIndices.add(history.length - 1);
    } else {
      // 3 dates: start, middle, end
      dateIndices.add(0);
      dateIndices.add((history.length - 1) ~/ 2);
      dateIndices.add(history.length - 1);
    }

    final textStyle = TextStyle(
      color: Palette.textSecondary,
      fontSize: 10,
      fontWeight: FontWeight.w500,
    );

    for (final index in dateIndices) {
      if (index < points.length) {
        final date = history[index].createdAt;
        final dateText = _formatDate(date, period);
        
        // Create text span
        final textSpan = TextSpan(
          text: dateText,
          style: textStyle,
        );
        final textPainter = TextPainter(
          text: textSpan,
          textAlign: TextAlign.center,
          textDirection: TextDirection.ltr,
        );
        textPainter.layout();
        
        // Position text at bottom, centered on the point
        final textX = points[index].dx - (textPainter.width / 2);
        final textY = chartHeight + 4; // Position below chart
        
        // Ensure text doesn't go outside bounds
        final adjustedX = textX.clamp(0.0, size.width - textPainter.width);
        
        textPainter.paint(canvas, Offset(adjustedX, textY));
      }
    }
  }

  String _formatDate(DateTime date, String period) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dateOnly = DateTime(date.year, date.month, date.day);
    final daysDiff = today.difference(dateOnly).inDays;

    if (daysDiff == 0) {
      return 'Today';
    } else if (daysDiff == 1) {
      return 'Yesterday';
    } else if (period == 'Weekly' && daysDiff < 7) {
      // For weekly, show day name
      final weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      return weekdays[date.weekday - 1];
    } else {
      // For monthly or older dates, show M/D format
      return '${date.month}/${date.day}';
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _AddFriendsSearchField extends HookWidget {
  final Function(String) onSearchChanged;

  const _AddFriendsSearchField({
    Key? key,
    required this.onSearchChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final searchController = useTextEditingController();

    return Container(
      decoration: BoxDecoration(
        color: Palette.backgroundTertiary,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Palette.glassBorder),
      ),
      child: TextField(
        controller: searchController,
        style: TextStyle(color: Palette.textPrimary),
        decoration: InputDecoration(
          hintText: 'Search by phone number or user ID...',
          hintStyle: TextStyle(color: Palette.textTertiary),
          prefixIcon: Icon(Icons.search, color: Palette.textSecondary),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        onChanged: onSearchChanged,
      ),
    );
  }
}

