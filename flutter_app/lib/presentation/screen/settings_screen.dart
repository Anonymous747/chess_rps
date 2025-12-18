import 'package:chess_rps/common/logger.dart';
import 'package:chess_rps/common/palette.dart';
import 'package:chess_rps/presentation/controller/auth_controller.dart';
import 'package:chess_rps/presentation/utils/app_router.dart';
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
                      _buildGameplaySection(),
                      const SizedBox(height: 24),
                      _buildAudioSection(),
                      const SizedBox(height: 24),
                      _buildPrivacySection(),
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

  Widget _buildGameplaySection() {
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
              _buildSettingItem(Icons.palette, 'Board Theme', 'Glass Dark', Icons.chevron_right),
              Divider(color: Palette.glassBorder, height: 1),
              _buildSettingItem(Icons.extension, 'Piece Set', 'Neon 3D', Icons.chevron_right),
              Divider(color: Palette.glassBorder, height: 1),
              _buildToggleItem(Icons.auto_awesome, 'Auto-Queen', 'Automatically promote to Queen', true),
              Divider(color: Palette.glassBorder, height: 1),
              _buildToggleItem(Icons.check_circle, 'Confirm Moves', '', false),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAudioSection() {
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
                                color: Palette.purpleAccentLight.withOpacity(0.1),
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
                            '80%',
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
                      value: 0.8,
                      onChanged: (value) {},
                      activeColor: Palette.purpleAccent,
                      inactiveColor: Palette.backgroundSecondary,
                    ),
                  ],
                ),
              ),
              Divider(color: Palette.glassBorder, height: 1),
              _buildToggleItem(Icons.notifications_active, 'Push Notifications', '', true),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPrivacySection() {
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
              _buildSettingItem(Icons.lock, 'Privacy Policy', null, Icons.open_in_new),
              Divider(color: Palette.glassBorder, height: 1),
              _buildToggleItem(Icons.visibility, 'Online Status', 'Visible to friends only', true),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSettingItem(IconData icon, String title, String? subtitle, IconData trailing) {
    return ListTile(
      leading: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: Palette.purpleAccent.withOpacity(0.1),
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

  Widget _buildToggleItem(IconData icon, String title, String subtitle, bool value) {
    return ListTile(
      leading: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: Palette.purpleAccent.withOpacity(0.1),
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
        onChanged: (newValue) {},
        activeColor: Palette.purpleAccent,
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
          backgroundColor: Palette.error.withOpacity(0.1),
          foregroundColor: Palette.error,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: Palette.error.withOpacity(0.2)),
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
}
