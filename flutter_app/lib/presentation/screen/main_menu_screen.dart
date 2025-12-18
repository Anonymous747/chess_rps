import 'package:chess_rps/common/logger.dart';
import 'package:chess_rps/common/palette.dart';
import 'package:chess_rps/presentation/controller/auth_controller.dart';
import 'package:chess_rps/presentation/utils/app_router.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class MainMenuScreen extends HookConsumerWidget {
  static const routeName = '/main-menu';

  const MainMenuScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authUser = ref.watch(authControllerProvider).valueOrNull;
    final username = authUser?.phoneNumber ?? 'Player';
    final level = 42; // Placeholder - can be fetched from backend later
    final rating = 1250; // Placeholder - can be fetched from backend later
    final progress = 0.65; // Placeholder - 65% progress to next level
    final onlineFriends = 3; // Placeholder

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
              // User Profile Header
              _buildUserProfileHeader(
                context,
                username: username,
                level: level,
                progress: progress,
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
                      _buildVariationGamesCard(context),
                      const SizedBox(height: 16),
                      _buildTournamentGamesCard(context),
                      
                      const SizedBox(height: 24),
                      
                      // Info Cards Grid
                      _buildInfoCardsGrid(
                        context,
                        rating: rating,
                        onlineFriends: onlineFriends,
                      ),
                      
                      const SizedBox(height: 100), // Space for bottom nav
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(context),
    );
  }

  static Widget _buildUserProfileHeader(
    BuildContext context, {
    required String username,
    required int level,
    required double progress,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          // Avatar with online indicator
          Stack(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Palette.purpleAccent,
                      Palette.purpleAccentDark,
                    ],
                  ),
                  border: Border.all(
                    color: Palette.purpleAccentLight,
                    width: 2,
                  ),
                ),
                child: Icon(
                  Icons.person,
                  color: Palette.textPrimary,
                  size: 32,
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
          
          // User Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Grandmaster', // Placeholder title
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Palette.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Level $level Strategist',
                  style: TextStyle(
                    fontSize: 14,
                    color: Palette.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                // Progress Bar
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
          
          // Notifications
          IconButton(
            onPressed: () {
              AppLogger.info('Notifications tapped', tag: 'MainMenu');
              // TODO: Navigate to notifications screen when created
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

  static Widget _buildVariationGamesCard(BuildContext context) {
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
            color: Palette.purpleAccent.withOpacity(0.3),
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
            AppLogger.info('Variation Games tapped', tag: 'MainMenu');
            context.push(AppRoutes.modeSelector);
          },
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                // Icon
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.sports_esports,
                    color: Palette.textPrimary,
                    size: 28,
                  ),
                ),
                
                const SizedBox(width: 16),
                
                // Content
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
                              color: Colors.white.withOpacity(0.2),
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
                
                // Play Button
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
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

  static Widget _buildTournamentGamesCard(BuildContext context) {
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
            color: Palette.black.withOpacity(0.2),
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
            AppLogger.info('Tournament Games tapped', tag: 'MainMenu');
            context.push(AppRoutes.events);
          },
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                // Trophy Icon
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Palette.gold.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.emoji_events,
                    color: Palette.gold,
                    size: 32,
                  ),
                ),
                
                const SizedBox(width: 16),
                
                // Content
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
                              color: Palette.gold.withOpacity(0.2),
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
            AppLogger.info('Rating tapped', tag: 'MainMenu');
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
            AppLogger.info('Collection tapped', tag: 'MainMenu');
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
            AppLogger.info('Friends tapped', tag: 'MainMenu');
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
            AppLogger.info('Settings tapped', tag: 'MainMenu');
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
            color: Palette.black.withOpacity(0.1),
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
                        color: iconColor.withOpacity(0.2),
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

  Widget _buildBottomNavigationBar(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Palette.backgroundSecondary.withOpacity(0.8),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Palette.black.withOpacity(0.2),
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
                icon: Icons.home,
                label: 'Home',
                isActive: true,
                onTap: () {
                  // Already on home
                },
              ),
              _buildNavItem(
                context,
                icon: Icons.emoji_events,
                label: 'Events',
                isActive: false,
                onTap: () {
                  AppLogger.info('Events tapped', tag: 'MainMenu');
                  context.push(AppRoutes.events);
                },
              ),
              // Central Play Button
              GestureDetector(
                onTap: () {
                  AppLogger.info('Quick play tapped', tag: 'MainMenu');
                  context.push(AppRoutes.modeSelector);
                },
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Palette.purpleAccent,
                        Palette.purpleAccentDark,
                      ],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Palette.purpleAccent.withOpacity(0.4),
                        blurRadius: 15,
                        spreadRadius: 0,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.play_arrow,
                    color: Palette.textPrimary,
                    size: 32,
                  ),
                ),
              ),
              _buildNavItem(
                context,
                icon: Icons.chat_bubble_outline,
                label: 'Chat',
                isActive: false,
                onTap: () {
                  AppLogger.info('Chat tapped', tag: 'MainMenu');
                  context.push(AppRoutes.chat);
                },
              ),
              _buildNavItem(
                context,
                icon: Icons.person_outline,
                label: 'Profile',
                isActive: false,
                onTap: () {
                  AppLogger.info('Profile tapped', tag: 'MainMenu');
                  context.push(AppRoutes.profile);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isActive ? Palette.purpleAccent : Palette.textSecondary,
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isActive ? Palette.purpleAccent : Palette.textSecondary,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
