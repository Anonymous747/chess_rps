import 'package:chess_rps/common/enum.dart';
import 'package:chess_rps/common/logger.dart';
import 'package:chess_rps/common/palette.dart';
import 'package:chess_rps/data/service/socket/game_room_handler.dart';
import 'package:chess_rps/presentation/mediator/game_mode_mediator.dart';
import 'package:chess_rps/presentation/screen/play_flow_screen.dart';
import 'package:chess_rps/presentation/utils/app_router.dart';
import 'package:chess_rps/presentation/widget/dashboard_navigation_menu.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

const _aiOpponentText = 'Play with AI';
const _aiOpponentTextSoon = 'Скоро...';
const _onlineOpponentText = 'Play Online';

class OpponentSelector extends ConsumerStatefulWidget {
  static const routeName = "opponentSelector";

  const OpponentSelector({Key? key}) : super(key: key);

  @override
  ConsumerState<OpponentSelector> createState() => _OpponentSelectorState();
}

class _OpponentSelectorState extends ConsumerState<OpponentSelector> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: const DashboardNavigationMenu(currentIndexOverride: 2),
      body: OpponentSelectorContent(),
    );
  }
}

/// Content widget for opponent selector (without Scaffold)
/// Can be used standalone or within PlayFlowScreen
class OpponentSelectorContent extends ConsumerWidget {
  const OpponentSelectorContent({Key? key}) : super(key: key);

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
                          ref.read(playFlowStateProvider.notifier).goBackToModeSelector();
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
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
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
                              child: Icon(
                                Icons.people,
                                size: 48,
                                color: Palette.accent,
                              ),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'Select Opponent',
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
                                'Choose who you want to play with',
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
                      const SizedBox(height: 48),
                      // Opponent Buttons
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          children: [
                            _buildOpponentButton(
                              context,
                              ref,
                              title: GameModesMediator.gameMode == GameMode.rps 
                                  ? _aiOpponentTextSoon 
                                  : _aiOpponentText,
                              icon: Icons.smart_toy,
                              color: Palette.accent,
                              onPressed: GameModesMediator.gameMode == GameMode.rps
                                  ? null // Disabled in RPS mode
                                  : () {
                                      AppLogger.info('User selected AI opponent',
                                          tag: 'OpponentSelector');
                                      ref.read(playFlowStateProvider.notifier).goToDifficultySelector();
                                    },
                            ),
                            const SizedBox(height: 20),
                            _buildOpponentButton(
                              context,
                              ref,
                              title: _onlineOpponentText,
                              icon: Icons.people,
                              color: Palette.purpleAccent,
                              onPressed: () async {
                                AppLogger.info('Finding match for online play',
                                    tag: 'OpponentSelector');
                                try {
                                  AppLogger.info('User selected online opponent',
                                      tag: 'OpponentSelector');
                                  GameModesMediator.changeOpponentMode(OpponentMode.socket);
                                  // Find match - either joins waiting room or creates new one
                                  final roomHandler = GameRoomHandler();
                                  final roomCode = await roomHandler.findMatch(
                                      GameModesMediator.gameMode == GameMode.classical
                                          ? 'classical'
                                          : 'rps');

                                  // Store room code in mediator for GameController
                                  GameModesMediator.setRoomCode(roomCode);

                                  // Don't dispose the handler - the waiting room will take ownership
                                  // The waiting room will dispose it if not reused by GameController

                                  if (context.mounted) {
                                    AppLogger.info('Navigating to waiting room: $roomCode',
                                        tag: 'OpponentSelector');
                                    context.push('${AppRoutes.waitingRoom}?roomCode=$roomCode');
                                  }
                                } catch (e) {
                                  AppLogger.error('Failed to find match: $e',
                                      tag: 'OpponentSelector', error: e);
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Failed to find match: $e'),
                                        backgroundColor: Palette.error,
                                      ),
                                    );
                                  }
                                }
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
    );
  }

  Widget _buildOpponentButton(
    BuildContext context,
    WidgetRef ref, {
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback? onPressed, // Changed to nullable
  }) {
    final isEnabled = onPressed != null;
    final effectiveColor = isEnabled ? color : Palette.textSecondary;
    
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: isEnabled ? [
          BoxShadow(
            color: color.withValues(alpha: 0.3),
            blurRadius: 20,
            spreadRadius: 0,
            offset: const Offset(0, 8),
          ),
        ] : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(16),
          child: Opacity(
            opacity: isEnabled ? 1.0 : 0.5,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: Palette.backgroundElevated,
                border: Border.all(
                  color: effectiveColor.withValues(alpha: 0.5),
                  width: 2,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: effectiveColor.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      icon,
                      size: 28,
                      color: effectiveColor,
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
                  if (isEnabled)
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 18,
                      color: effectiveColor,
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
