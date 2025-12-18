import 'package:chess_rps/common/logger.dart';
import 'package:chess_rps/common/palette.dart';
import 'package:chess_rps/data/service/settings/settings_service.dart';
import 'package:chess_rps/presentation/controller/auth_controller.dart';
import 'package:chess_rps/presentation/controller/settings_controller.dart';
import 'package:chess_rps/presentation/utils/app_router.dart';
import 'package:chess_rps/presentation/widget/settings/piece_set_selection_dialog.dart';
import 'package:chess_rps/presentation/widget/settings/theme_selection_dialog.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class SettingsScreen extends HookConsumerWidget {
  static const routeName = '/settings';

  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
                      onPressed: () => context.pop(),
                      icon: Icon(Icons.arrow_back, color: Palette.textSecondary),
                      style: IconButton.styleFrom(
                        backgroundColor: Palette.backgroundTertiary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: Palette.glassBorder),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Settings',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Palette.textPrimary,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () {},
                      icon: Icon(Icons.help_outline, color: Palette.textSecondary),
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
                      _buildAccountSection(context, ref),
                      const SizedBox(height: 24),
                      _buildGameplaySection(context, ref),
                      const SizedBox(height: 24),
                      _buildAudioSection(context, ref),
                      const SizedBox(height: 24),
                      _buildPrivacySection(context, ref),
                      const SizedBox(height: 24),
                      _buildLogoutButton(context, ref),
                      const SizedBox(height: 24),
                      Text(
                        'Chess RPS v2.4.1 (Build 890)',
                        style: TextStyle(
                          fontSize: 12,
                          color: Palette.textTertiary,
                        ),
                      ),
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

  Widget _buildAccountSection(BuildContext context, WidgetRef ref) {
    final authUser = ref.watch(authControllerProvider).valueOrNull;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'ACCOUNT',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Palette.textTertiary,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Palette.backgroundTertiary,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Palette.glassBorder),
          ),
          child: Column(
            children: [
              ListTile(
                leading: Stack(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Palette.purpleAccent, Palette.purpleAccentDark],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(Icons.person, color: Palette.textPrimary, size: 28),
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
                          border: Border.all(color: Palette.backgroundTertiary, width: 2),
                        ),
                      ),
                    ),
                  ],
                ),
                title: Text(
                  'Grandmaster',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Palette.textPrimary,
                  ),
                ),
                subtitle: Text(
                  authUser?.phoneNumber ?? 'user@chessrps.com',
                  style: TextStyle(color: Palette.textSecondary),
                ),
                trailing: Icon(Icons.chevron_right, color: Palette.textSecondary),
              ),
              Divider(color: Palette.glassBorder, height: 1),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () {},
                      child: Text('Edit Profile', style: TextStyle(color: Palette.textSecondary)),
                    ),
                  ),
                  Container(width: 1, height: 40, color: Palette.glassBorder),
                  Expanded(
                    child: TextButton(
                      onPressed: () {},
                      child: Text('Membership', style: TextStyle(color: Palette.textSecondary)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildGameplaySection(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(settingsControllerProvider);
    
    return settingsAsync.when(
      data: (settings) => _buildGameplaySectionContent(context, ref, settings),
      loading: () => const SizedBox(height: 200, child: Center(child: CircularProgressIndicator())),
      error: (error, stack) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'GAMEPLAY',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Palette.textTertiary,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Palette.backgroundTertiary,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Palette.error),
            ),
            child: Text('Error loading settings', style: TextStyle(color: Palette.error)),
          ),
        ],
      ),
    );
  }

  Widget _buildGameplaySectionContent(BuildContext context, WidgetRef ref, UserSettings settings) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'GAMEPLAY',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Palette.textTertiary,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Palette.backgroundTertiary,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Palette.glassBorder),
          ),
          child: Column(
            children: [
              _buildSettingItem(
                Icons.palette,
                'Board Theme',
                _formatThemeName(settings.boardTheme),
                Icons.chevron_right,
                onTap: () {
                  AppLogger.info('Theme selection tapped', tag: 'SettingsScreen');
                  showDialog(
                    context: context,
                    builder: (context) => ThemeSelectionDialog(
                      currentTheme: settings.boardTheme,
                      onThemeSelected: (theme) {
                        ref.read(settingsControllerProvider.notifier).updateBoardTheme(theme);
                      },
                    ),
                  );
                },
              ),
              Divider(color: Palette.glassBorder, height: 1),
              _buildSettingItem(
                Icons.extension,
                'Piece Set',
                _formatPieceSetName(settings.pieceSet),
                Icons.chevron_right,
                onTap: () {
                  AppLogger.info('Piece set selection tapped', tag: 'SettingsScreen');
                  showDialog(
                    context: context,
                    builder: (context) => PieceSetSelectionDialog(
                      currentPieceSet: settings.pieceSet,
                      onPieceSetSelected: (pieceSet) {
                        ref.read(settingsControllerProvider.notifier).updatePieceSet(pieceSet);
                      },
                    ),
                  );
                },
              ),
              Divider(color: Palette.glassBorder, height: 1),
              _buildToggleItem(
                Icons.auto_awesome,
                'Auto-Queen',
                'Automatically promote to Queen',
                settings.autoQueen,
                onChanged: (value) {
                  ref.read(settingsControllerProvider.notifier).updateAutoQueen(value);
                },
              ),
              Divider(color: Palette.glassBorder, height: 1),
              _buildToggleItem(
                Icons.check_circle,
                'Confirm Moves',
                '',
                settings.confirmMoves,
                onChanged: (value) {
                  ref.read(settingsControllerProvider.notifier).updateConfirmMoves(value);
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAudioSection(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(settingsControllerProvider);
    
    return settingsAsync.when(
      data: (settings) => _buildAudioSectionContent(context, ref, settings),
      loading: () => const SizedBox(height: 200, child: Center(child: CircularProgressIndicator())),
      error: (error, stack) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'AUDIO & SYNC',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Palette.textTertiary,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Palette.backgroundTertiary,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Palette.error),
            ),
            child: Text('Error loading settings', style: TextStyle(color: Palette.error)),
          ),
        ],
      ),
    );
  }

  Widget _buildAudioSectionContent(BuildContext context, WidgetRef ref, UserSettings settings) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'AUDIO & SYNC',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Palette.textTertiary,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Palette.backgroundTertiary,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Palette.glassBorder),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: Palette.purpleAccentLight.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(Icons.volume_up, color: Palette.purpleAccentLight, size: 20),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Master Volume',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Palette.textPrimary,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Palette.backgroundSecondary,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '${(settings.masterVolume * 100).toInt()}%',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Palette.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Slider(
                      value: settings.masterVolume,
                      onChanged: (value) {
                        ref.read(settingsControllerProvider.notifier).updateMasterVolume(value);
                      },
                      activeColor: Palette.purpleAccent,
                      inactiveColor: Palette.backgroundSecondary,
                    ),
                  ],
                ),
              ),
              Divider(color: Palette.glassBorder, height: 1),
              _buildToggleItem(
                Icons.notifications_active,
                'Push Notifications',
                '',
                settings.pushNotifications,
                onChanged: (value) {
                  ref.read(settingsControllerProvider.notifier).updatePushNotifications(value);
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPrivacySection(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(settingsControllerProvider);
    
    return settingsAsync.when(
      data: (settings) => _buildPrivacySectionContent(context, ref, settings),
      loading: () => const SizedBox(height: 200, child: Center(child: CircularProgressIndicator())),
      error: (error, stack) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'PRIVACY',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Palette.textTertiary,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Palette.backgroundTertiary,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Palette.error),
            ),
            child: Text('Error loading settings', style: TextStyle(color: Palette.error)),
          ),
        ],
      ),
    );
  }

  Widget _buildPrivacySectionContent(BuildContext context, WidgetRef ref, UserSettings settings) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'PRIVACY',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Palette.textTertiary,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Palette.backgroundTertiary,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Palette.glassBorder),
          ),
          child: Column(
            children: [
              _buildSettingItem(
                Icons.lock,
                'Privacy Policy',
                null,
                Icons.open_in_new,
                onTap: () {
                  // TODO: Open privacy policy URL
                  AppLogger.info('Privacy policy tapped', tag: 'SettingsScreen');
                },
              ),
              Divider(color: Palette.glassBorder, height: 1),
              _buildToggleItem(
                Icons.visibility,
                'Online Status',
                'Visible to friends only',
                settings.onlineStatusVisible,
                onChanged: (value) {
                  ref.read(settingsControllerProvider.notifier).updateOnlineStatusVisible(value);
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSettingItem(
    IconData icon,
    String title,
    String? subtitle,
    IconData trailing, {
    VoidCallback? onTap,
  }) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: Palette.purpleAccent.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: Palette.purpleAccent, size: 20),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Palette.textPrimary,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: TextStyle(color: Palette.textSecondary, fontSize: 12),
            )
          : null,
      trailing: Icon(trailing, color: Palette.textTertiary, size: 20),
    );
  }

  Widget _buildToggleItem(
    IconData icon,
    String title,
    String subtitle,
    bool value, {
    ValueChanged<bool>? onChanged,
  }) {
    return ListTile(
      leading: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: Palette.purpleAccent.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: Palette.purpleAccent, size: 20),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Palette.textPrimary,
        ),
      ),
      subtitle: subtitle.isNotEmpty
          ? Text(
              subtitle,
              style: TextStyle(color: Palette.textTertiary, fontSize: 12),
            )
          : null,
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeTrackColor: Palette.purpleAccent,
        activeThumbColor: Palette.textPrimary,
        thumbColor: WidgetStateProperty.resolveWith<Color>((Set<WidgetState> states) {
          if (states.contains(WidgetState.selected)) {
            return Palette.textPrimary;
          }
          return Palette.textSecondary;
        }),
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context, WidgetRef ref) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () async {
          await ref.read(authControllerProvider.notifier).logout();
          if (context.mounted) {
            context.go(AppRoutes.login);
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Palette.error.withValues(alpha: 0.1),
          foregroundColor: Palette.error,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: Palette.error.withValues(alpha: 0.2)),
          ),
        ),
        child: Text(
          'Log Out',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  String _formatThemeName(String theme) {
    // Convert snake_case to Title Case
    return theme.split('_').map((word) {
      if (word.isEmpty) return '';
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }

  String _formatPieceSetName(String pieceSet) {
    // Convert snake_case to Title Case
    return pieceSet.split('_').map((word) {
      if (word.isEmpty) return '';
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }
}

