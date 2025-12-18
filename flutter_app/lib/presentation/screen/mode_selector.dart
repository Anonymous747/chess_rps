import 'package:chess_rps/common/enum.dart';
import 'package:chess_rps/common/logger.dart';
import 'package:chess_rps/common/palette.dart';
import 'package:chess_rps/presentation/mediator/game_mode_mediator.dart';
import 'package:chess_rps/presentation/utils/app_router.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

const _normalModeText = 'Classical Mode';
const _rpsModeText = 'RPS Mode';

class ModeSelector extends StatelessWidget {
  static const routeName = "modeSelector";

  const ModeSelector({Key? key}) : super(key: key);

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
                                color: Palette.accent.withOpacity(0.1),
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
                                  color: Palette.accent.withOpacity(0.1),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Palette.accent.withOpacity(0.3),
                                    width: 2,
                                  ),
                                ),
                                child: Icon(
                                  Icons.sports_esports,
                                  size: 64,
                                  color: Palette.accent,
                                ),
                              ),
                              const SizedBox(height: 24),
                              const Text(
                                'Chess RPS',
                                style: TextStyle(
                                  fontSize: 36,
                                  fontWeight: FontWeight.bold,
                                  color: Palette.textPrimary,
                                  letterSpacing: 1.5,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Select Game Mode',
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
                        // Mode Buttons
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Column(
                            children: [
                              _buildModeButton(
                                context,
                                title: _normalModeText,
                                icon: Icons.sports_esports,
                                color: Palette.accent,
                                onPressed: () {
                                  AppLogger.info('Classical mode selected', tag: 'ModeSelector');
                                  GameModesMediator.changeGameMode(GameMode.classical);
                                  context.push(AppRoutes.opponentSelector);
                                },
                              ),
                              const SizedBox(height: 20),
                              _buildModeButton(
                                context,
                                title: _rpsModeText,
                                icon: Icons.handshake,
                                color: Palette.purpleAccent,
                                onPressed: () {
                                  AppLogger.info('RPS mode selected', tag: 'ModeSelector');
                                  GameModesMediator.changeGameMode(GameMode.rps);
                                  context.push(AppRoutes.opponentSelector);
                                },
                              ),
                            ],
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

  Widget _buildModeButton(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
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
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: Palette.backgroundElevated,
              border: Border.all(
                color: color.withOpacity(0.5),
                width: 2,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    size: 28,
                    color: color,
                  ),
                ),
                const SizedBox(width: 20),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Palette.textPrimary,
                    letterSpacing: 0.5,
                  ),
                ),
                const Spacer(),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 18,
                  color: color,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
