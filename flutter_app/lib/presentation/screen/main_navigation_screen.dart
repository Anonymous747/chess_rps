import 'package:chess_rps/common/logger.dart';
import 'package:chess_rps/common/palette.dart';
import 'package:chess_rps/presentation/controller/auth_controller.dart';
import 'package:chess_rps/presentation/controller/stats_controller.dart';
import 'package:chess_rps/presentation/screen/chat_screen.dart';
import 'package:chess_rps/presentation/screen/events_screen.dart';
import 'package:chess_rps/presentation/screen/profile_screen.dart';
import 'package:chess_rps/presentation/screen/mode_selector.dart';
import 'package:chess_rps/presentation/utils/app_router.dart';
import 'package:chess_rps/presentation/widget/user_avatar_widget.dart';
import 'package:chess_rps/presentation/widget/skeleton_loader.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final navigationIndexProvider = StateNotifierProvider<NavigationIndexNotifier, int>((ref) {
  return NavigationIndexNotifier();
});

class NavigationIndexNotifier extends StateNotifier<int> {
  NavigationIndexNotifier() : super(0); // 0: Home, 1: Events, 2: Play, 3: Chat, 4: Profile

  void setIndex(int index) {
    state = index;
  }
}

class MainNavigationScreen extends HookConsumerWidget {
  static const routeName = '/main-navigation';

  const MainNavigationScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(navigationIndexProvider);

    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (Widget child, Animation<double> animation) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.1, 0.0),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
              )),
              child: child,
            ),
          );
        },
        child: _getScreenForIndex(currentIndex),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(context, ref, currentIndex),
    );
  }

  Widget _getScreenForIndex(int index) {
    switch (index) {
      case 0:
        return const MainMenuContent(key: ValueKey('home'));
      case 1:
        return const EventsScreen(key: ValueKey('events'));
      case 2:
        return const ModeSelector(key: ValueKey('play'));
      case 3:
        return const ChatScreen(key: ValueKey('chat'));
      case 4:
        return const ProfileScreen(key: ValueKey('profile'));
      default:
        return const MainMenuContent(key: ValueKey('home'));
    }
  }

  Widget _buildBottomNavigationBar(
    BuildContext context,
    WidgetRef ref,
    int currentIndex,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Palette.backgroundSecondary.withValues(alpha: 0.8),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Palette.black.withValues(alpha: 0.2),
            blurRadius: 10,
            spreadRadius: 0,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                context,
                ref,
                icon: Icons.home,
                label: 'Home',
                index: 0,
                currentIndex: currentIndex,
              ),
              _buildNavItem(
                context,
                ref,
                icon: Icons.emoji_events,
                label: 'Events',
                index: 1,
                currentIndex: currentIndex,
              ),
              // Central Play Button (now part of navigation)
              _buildPlayNavItem(
                context,
                ref,
                currentIndex: currentIndex,
              ),
              _buildNavItem(
                context,
                ref,
                icon: Icons.chat_bubble_outline,
                label: 'Chat',
                index: 3,
                currentIndex: currentIndex,
              ),
              _buildNavItem(
                context,
                ref,
                icon: Icons.person_outline,
                label: 'Profile',
                index: 4,
                currentIndex: currentIndex,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context,
    WidgetRef ref, {
    required IconData icon,
    required String label,
    required int index,
    required int currentIndex,
  }) {
    final isActive = currentIndex == index;
    return GestureDetector(
      onTap: () {
        ref.read(navigationIndexProvider.notifier).setIndex(index);
        AppLogger.info('Navigation to $label', tag: 'MainNavigation');
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedScale(
              scale: isActive ? 1.1 : 1.0,
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isActive ? Palette.purpleAccent.withValues(alpha: 0.1) : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: isActive ? Palette.purpleAccent : Palette.textSecondary,
                  size: 24,
                ),
              ),
            ),
            const SizedBox(height: 4),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              style: TextStyle(
                fontSize: 12,
                color: isActive ? Palette.purpleAccent : Palette.textSecondary,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              ),
              child: Text(label),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlayNavItem(
    BuildContext context,
    WidgetRef ref, {
    required int currentIndex,
  }) {
    final isActive = currentIndex == 2;
    return GestureDetector(
      onTap: () {
        ref.read(navigationIndexProvider.notifier).setIndex(2);
        AppLogger.info('Navigation to Play', tag: 'MainNavigation');
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isActive
                ? [
                    Palette.purpleAccent,
                    Palette.purpleAccentDark,
                  ]
                : [
                    Palette.purpleAccent.withValues(alpha: 0.8),
                    Palette.purpleAccentDark.withValues(alpha: 0.8),
                  ],
          ),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Palette.purpleAccent.withValues(alpha: isActive ? 0.4 : 0.2),
              blurRadius: isActive ? 15 : 8,
              spreadRadius: 0,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: AnimatedScale(
          scale: isActive ? 1.1 : 1.0,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          child: Icon(
            Icons.play_arrow,
            color: Palette.textPrimary,
            size: 32,
          ),
        ),
      ),
    );
  }
}

// Separate widget for the main menu content (without bottom nav)
class MainMenuContent extends HookConsumerWidget {
  const MainMenuContent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authUser = ref.watch(authControllerProvider).valueOrNull;
    final username = authUser?.phoneNumber ?? 'Player';
    final statsAsync = ref.watch(statsControllerProvider);
    final onlineFriends = 3;

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
            // User Profile Header
            statsAsync.when(
              data: (stats) {
                final level = stats.level;
                final levelName = stats.levelName ?? 'Novice';
                final levelProgress = stats.levelProgress;
                final progress = levelProgress != null && levelProgress.xpForNextLevel > 0
                    ? levelProgress.currentLevelXp / levelProgress.xpForNextLevel
                    : 0.0;
                return _MainMenuContentHelper._buildUserProfileHeader(
                  context,
                  username: username,
                  level: level,
                  levelName: levelName,
                  progress: progress,
                );
              },
              loading: () => _MainMenuContentHelper._buildUserProfileHeader(
                context,
                username: username,
                level: 0,
                levelName: 'Novice',
                progress: 0.0,
              ),
              error: (_, __) => _MainMenuContentHelper._buildUserProfileHeader(
                context,
                username: username,
                level: 0,
                levelName: 'Novice',
                progress: 0.0,
              ),
            ),
            
            // Main Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 24),
                    
                    // Game Mode Cards
                    _MainMenuContentHelper._buildVariationGamesCard(context, ref),
                    const SizedBox(height: 16),
                    _MainMenuContentHelper._buildTournamentGamesCard(context, ref),
                    
                    const SizedBox(height: 24),
                    
                    // Info Cards Grid
                    statsAsync.when(
                      data: (stats) => _MainMenuContentHelper._buildInfoCardsGrid(
                        context,
                        rating: stats.rating,
                        onlineFriends: onlineFriends,
                      ),
                      loading: () => GridView.count(
                        crossAxisCount: 2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        childAspectRatio: 1.1,
                        children: [
                          SkeletonCard(height: 120),
                          SkeletonCard(height: 120),
                        ],
                      ),
                      error: (_, __) => _MainMenuContentHelper._buildInfoCardsGrid(
                        context,
                        rating: 1200,
                        onlineFriends: onlineFriends,
                      ),
                    ),
                    
                    const SizedBox(height: 100), // Space for bottom nav
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Helper class for MainMenuContent methods
class _MainMenuContentHelper {

  static Widget _buildUserProfileHeader(
    BuildContext context, {
    required String username,
    required int level,
    required String levelName,
    required double progress,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Palette.purpleAccent.withValues(alpha: 0.1),
            blurRadius: 20,
            spreadRadius: 0,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Stack(
            children: [
              UserAvatarWidget(
                size: 60,
                border: Border.all(
                  color: Palette.purpleAccentLight,
                  width: 2,
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: Palette.onlineGreen,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Palette.background,
                      width: 2,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  levelName,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Palette.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Level $level',
                  style: TextStyle(
                    fontSize: 14,
                    color: Palette.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: Container(
                    height: 6,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      color: Palette.backgroundTertiary,
                    ),
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: progress,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          gradient: LinearGradient(
                            colors: [
                              Palette.purpleAccent,
                              Palette.purpleAccentLight,
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              AppLogger.info('Notifications tapped', tag: 'MainNavigation');
            },
            icon: Stack(
              children: [
                Icon(
                  Icons.notifications_outlined,
                  color: Palette.textSecondary,
                  size: 28,
                ),
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: Palette.error,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildVariationGamesCard(BuildContext context, WidgetRef ref) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Palette.purpleAccent,
            Palette.purpleAccentDark,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Palette.purpleAccent.withValues(alpha: 0.3),
            blurRadius: 20,
            spreadRadius: 0,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            AppLogger.info('Variation Games tapped', tag: 'MainNavigation');
            context.push(AppRoutes.modeSelector);
          },
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.sports_esports,
                    color: Palette.textPrimary,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'FEATURED',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Palette.textPrimary,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Variation Games',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Palette.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'RPS, Blitz, Bullet & Chaos Modes',
                        style: TextStyle(
                          fontSize: 14,
                          color: Palette.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.play_arrow,
                    color: Palette.textPrimary,
                    size: 28,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static Widget _buildTournamentGamesCard(BuildContext context, WidgetRef ref) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Palette.backgroundTertiary,
        border: Border(
          left: BorderSide(
            color: Palette.gold,
            width: 4,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Palette.gold.withValues(alpha: 0.3),
            blurRadius: 20,
            spreadRadius: 0,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Palette.black.withValues(alpha: 0.1),
            blurRadius: 10,
            spreadRadius: 0,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            AppLogger.info('Tournament Games tapped', tag: 'MainNavigation');
            // Switch to Events tab (index 1) in the navigation
            ref.read(navigationIndexProvider.notifier).setIndex(1);
          },
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Palette.gold.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.emoji_events,
                    color: Palette.gold,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Tournament Games',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Palette.textPrimary,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Palette.gold.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              '• LIVE',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Palette.gold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Compete in daily events and win exclusive skins.',
                        style: TextStyle(
                          fontSize: 14,
                          color: Palette.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static Widget _buildInfoCardsGrid(
    BuildContext context, {
    required int rating,
    required int onlineFriends,
  }) {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.1,
      children: [
        _buildInfoCard(
          context,
          icon: Icons.trending_up,
          iconColor: Palette.success,
          title: 'Rating',
          subtitle: '$rating MMR',
          trailing: Icon(
            Icons.trending_up,
            color: Palette.success,
            size: 20,
          ),
          onTap: () {
            AppLogger.info('Rating tapped', tag: 'MainNavigation');
            context.push(AppRoutes.rating);
          },
        ),
        _buildInfoCard(
          context,
          icon: Icons.collections,
          iconColor: Palette.purpleAccentLight,
          title: 'Collection',
          subtitle: 'Skins & Boards',
          onTap: () {
            AppLogger.info('Collection tapped', tag: 'MainNavigation');
            context.push(AppRoutes.collection);
          },
        ),
        _buildInfoCard(
          context,
          icon: Icons.people,
          iconColor: Palette.info,
          title: 'Friends',
          subtitle: '• $onlineFriends Online',
          trailing: Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: Palette.onlineGreen,
              shape: BoxShape.circle,
            ),
          ),
          onTap: () {
            AppLogger.info('Friends tapped', tag: 'MainNavigation');
            context.push(AppRoutes.friends);
          },
        ),
        _buildInfoCard(
          context,
          icon: Icons.settings,
          iconColor: Palette.textSecondary,
          title: 'Settings',
          subtitle: 'Preferences',
          onTap: () {
            AppLogger.info('Settings tapped', tag: 'MainNavigation');
            context.push(AppRoutes.settings);
          },
        ),
      ],
    );
  }

  static Widget _buildInfoCard(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    Widget? trailing,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Palette.backgroundTertiary,
        border: Border.all(
          color: Palette.glassBorder,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: iconColor.withValues(alpha: 0.2),
            blurRadius: 15,
            spreadRadius: 0,
            offset: const Offset(0, 6),
          ),
          BoxShadow(
            color: Palette.black.withValues(alpha: 0.1),
            blurRadius: 10,
            spreadRadius: 0,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: iconColor.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        icon,
                        color: iconColor,
                        size: 24,
                      ),
                    ),
                    if (trailing != null) trailing,
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Palette.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: Palette.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}



