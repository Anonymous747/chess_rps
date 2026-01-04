import 'package:chess_rps/common/logger.dart';
import 'package:chess_rps/common/palette.dart';
import 'package:chess_rps/data/service/settings/settings_service.dart';
import 'package:chess_rps/presentation/controller/auth_controller.dart';
import 'package:chess_rps/presentation/controller/locale_controller.dart';
import 'package:chess_rps/presentation/controller/settings_controller.dart';
import 'package:chess_rps/presentation/controller/stats_controller.dart';
import 'package:chess_rps/presentation/utils/app_router.dart';
import 'package:chess_rps/presentation/widget/settings/language_selection_dialog.dart';
import 'package:chess_rps/presentation/widget/settings/piece_set_selection_dialog.dart';
import 'package:chess_rps/presentation/widget/settings/theme_selection_dialog.dart';
import 'package:flutter/material.dart';
import 'package:chess_rps/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class SettingsScreen extends HookConsumerWidget {
  static const routeName = '/settings';

  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    
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
                      l10n.settings,
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
                      _buildGeneralSection(context, ref),
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
                        AppLocalizations.of(context)!.appVersion,
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
    final l10n = AppLocalizations.of(context)!;
    final authUser = ref.watch(authControllerProvider).valueOrNull;
    final leaderboardAsync = ref.watch(leaderboardProvider(1000)); // Fetch large leaderboard to find user position
    
    // Find user's position in leaderboard
    int? userPosition;
    if (authUser != null && leaderboardAsync.hasValue) {
      final leaderboard = leaderboardAsync.value!;
      try {
        final userEntry = leaderboard.firstWhere(
          (entry) => entry.userId == authUser.userId,
        );
        userPosition = userEntry.rank;
      } catch (e) {
        // User not found in leaderboard (might not be in top 1000)
        userPosition = null;
      }
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.account,
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
                  l10n.grandmaster,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Palette.textPrimary,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      authUser?.phoneNumber ?? 'user@chessrps.com',
                      style: TextStyle(color: Palette.textSecondary),
                    ),
                    if (userPosition != null) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.leaderboard,
                            size: 14,
                            color: Palette.purpleAccent,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            l10n.ratingPosition(userPosition),
                            style: TextStyle(
                              color: Palette.purpleAccent,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ] else if (leaderboardAsync.isLoading) ...[
                      const SizedBox(height: 4),
                      SizedBox(
                        width: 12,
                        height: 12,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Palette.purpleAccent),
                        ),
                      ),
                    ],
                  ],
                ),
                trailing: Icon(Icons.chevron_right, color: Palette.textSecondary),
              ),
              Divider(color: Palette.glassBorder, height: 1),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () {},
                      child: Text(l10n.editProfile, style: TextStyle(color: Palette.textSecondary)),
                    ),
                  ),
                  Container(width: 1, height: 40, color: Palette.glassBorder),
                  Expanded(
                    child: TextButton(
                      onPressed: () {},
                      child: Text(l10n.membership, style: TextStyle(color: Palette.textSecondary)),
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

  Widget _buildGeneralSection(BuildContext context, WidgetRef ref) {
    final localeAsync = ref.watch(localeNotifierProvider);
    final l10n = AppLocalizations.of(context)!;
    
    return localeAsync.when(
      data: (locale) {
        String localeName;
        if (locale.languageCode == 'ru') {
          localeName = l10n.russian;
        } else {
          localeName = l10n.english;
        }
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.general,
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
              child: _buildSettingItem(
                Icons.language,
                l10n.language,
                localeName,
                Icons.chevron_right,
                onTap: () {
                  AppLogger.info('Language selection tapped', tag: 'SettingsScreen');
                  showDialog(
                    context: context,
                    builder: (dialogContext) => LanguageSelectionDialog(
                      currentLocale: locale,
                    ),
                  );
                },
              ),
            ),
          ],
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'GENERAL',
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
            child: Text(l10n.errorLoadingLanguageSettings, style: TextStyle(color: Palette.error)),
          ),
        ],
      ),
    );
  }

  Widget _buildGameplaySection(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final settingsAsync = ref.watch(settingsControllerProvider);
    
    return settingsAsync.when(
      data: (settings) => _buildGameplaySectionContent(context, ref, settings),
      loading: () => Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Palette.accent),
          ),
        ),
      ),
      error: (error, stack) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.gameplay,
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
            child: Text(l10n.errorLoadingSettings, style: TextStyle(color: Palette.error)),
          ),
        ],
      ),
    );
  }

  Widget _buildGameplaySectionContent(BuildContext context, WidgetRef ref, UserSettings settings) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.gameplay,
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
                l10n.boardTheme,
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
                l10n.pieceSet,
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
                l10n.autoQueen,
                l10n.autoQueenDescription,
                settings.autoQueen,
                onChanged: (value) {
                  ref.read(settingsControllerProvider.notifier).updateAutoQueen(value);
                },
              ),
              Divider(color: Palette.glassBorder, height: 1),
              _buildToggleItem(
                Icons.check_circle,
                l10n.confirmMoves,
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
    final l10n = AppLocalizations.of(context)!;
    final settingsAsync = ref.watch(settingsControllerProvider);
    
    return settingsAsync.when(
      data: (settings) => _buildAudioSectionContent(context, ref, settings),
      loading: () => Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Palette.accent),
          ),
        ),
      ),
      error: (error, stack) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.audioAndSync,
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
            child: Text(l10n.errorLoadingSettings, style: TextStyle(color: Palette.error)),
          ),
        ],
      ),
    );
  }

  Widget _buildAudioSectionContent(BuildContext context, WidgetRef ref, UserSettings settings) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.audioAndSync,
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
                              l10n.masterVolume,
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
                l10n.pushNotifications,
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
    final l10n = AppLocalizations.of(context)!;
    final settingsAsync = ref.watch(settingsControllerProvider);
    
    return settingsAsync.when(
      data: (settings) => _buildPrivacySectionContent(context, ref, settings),
      loading: () => Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Palette.accent),
          ),
        ),
      ),
      error: (error, stack) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.privacy,
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
            child: Text(l10n.errorLoadingSettings, style: TextStyle(color: Palette.error)),
          ),
        ],
      ),
    );
  }

  Widget _buildPrivacySectionContent(BuildContext context, WidgetRef ref, UserSettings settings) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.privacy,
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
                l10n.privacyPolicy,
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
                l10n.onlineStatus,
                l10n.onlineStatusDescription,
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
    final l10n = AppLocalizations.of(context)!;
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
          l10n.logout,
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

