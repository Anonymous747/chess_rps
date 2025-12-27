import 'package:chess_rps/common/logger.dart';
import 'package:chess_rps/common/palette.dart';
import 'package:chess_rps/presentation/screen/main_navigation_screen.dart';
import 'package:chess_rps/presentation/utils/app_router.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// Reusable dashboard navigation menu widget
/// This provides the bottom navigation bar that's used across the app
class DashboardNavigationMenu extends ConsumerWidget {
  final int? currentIndexOverride;

  const DashboardNavigationMenu({
    Key? key,
    this.currentIndexOverride,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = currentIndexOverride ?? ref.watch(navigationIndexProvider);
    final effectiveIndex = currentIndex ?? 0;

    return Container(
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
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
                currentIndex: effectiveIndex,
              ),
              _buildNavItem(
                context,
                ref,
                icon: Icons.emoji_events,
                label: 'Events',
                index: 1,
                currentIndex: effectiveIndex,
              ),
              // Central Play Button (now part of navigation)
              _buildPlayNavItem(
                context,
                ref,
                currentIndex: effectiveIndex,
              ),
              _buildNavItem(
                context,
                ref,
                icon: Icons.chat_bubble_outline,
                label: 'Chat',
                index: 3,
                currentIndex: effectiveIndex,
              ),
              _buildNavItem(
                context,
                ref,
                icon: Icons.person_outline,
                label: 'Profile',
                index: 4,
                currentIndex: effectiveIndex,
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
        AppLogger.info('Navigation to $label', tag: 'DashboardNavigationMenu');
        // Set the navigation index - this will trigger smooth transitions in MainNavigationScreen
        ref.read(navigationIndexProvider.notifier).setIndex(index);
        // Navigate to main menu if not already there - use go for smooth transition
        context.go(AppRoutes.mainMenu);
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
        AppLogger.info('Navigation to Play', tag: 'DashboardNavigationMenu');
        // Set the navigation index - this will trigger smooth transitions in MainNavigationScreen
        ref.read(navigationIndexProvider.notifier).setIndex(2);
        // Navigate to main menu if not already there - use go for smooth transition
        context.go(AppRoutes.mainMenu);
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

