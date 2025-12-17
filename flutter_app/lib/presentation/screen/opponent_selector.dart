import 'package:chess_rps/common/enum.dart';
import 'package:chess_rps/common/logger.dart';
import 'package:chess_rps/common/palette.dart';
import 'package:chess_rps/data/service/socket/game_room_handler.dart';
import 'package:chess_rps/presentation/mediator/game_mode_mediator.dart';
import 'package:chess_rps/presentation/utils/app_router.dart';
import 'package:chess_rps/presentation/widget/loading_overlay.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

const _aiOpponentText = 'Play with AI';
const _onlineOpponentText = 'Play Online';

class OpponentSelector extends StatefulWidget {
  static const routeName = "opponentSelector";

  const OpponentSelector({Key? key}) : super(key: key);

  @override
  State<OpponentSelector> createState() => _OpponentSelectorState();
}

class _OpponentSelectorState extends State<OpponentSelector> {
  bool _isCreatingRoom = false;

  @override
  Widget build(BuildContext context) {
    return LoadingOverlay(
      isLoading: _isCreatingRoom,
      message: 'Creating room...',
      child: Scaffold(
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
                // Back button and title
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
                      const Expanded(
                        child: Text(
                          'Select Opponent',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Palette.textPrimary,
                            letterSpacing: 0.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(width: 56), // Balance for back button
                    ],
                  ),
                ),
                Expanded(
                  child: Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: Palette.backgroundTertiary,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: Palette.glassBorder,
                                width: 1,
                              ),
                            ),
                            child: Text(
                              'Choose your opponent:',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Palette.textSecondary,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                          const SizedBox(height: 40),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Column(
                              children: [
                                _buildOpponentButton(
                                  context,
                                  title: _aiOpponentText,
                                  icon: Icons.smart_toy,
                                  color: Palette.accent,
                              onPressed: () {
                                GameModesMediator().changeOpponentMode(OpponentMode.ai);
                                context.push(AppRoutes.chess);
                              },
                                ),
                                const SizedBox(height: 20),
                                _buildOpponentButton(
                                  context,
                                  title: _onlineOpponentText,
                                  icon: Icons.people,
                                  color: Palette.purpleAccent,
                                  onPressed: () async {
                                    AppLogger.info('Creating online game room',
                                        tag: 'OpponentSelector');
                                    setState(() {
                                      _isCreatingRoom = true;
                                    });

                                    try {
                                      GameModesMediator().changeOpponentMode(OpponentMode.socket);
                                      // Create room and navigate to waiting room
                                      final roomHandler = GameRoomHandler();
                                      final roomCode = await roomHandler.createRoom(
                                          GameModesMediator.gameMode == GameMode.classical
                                              ? 'classical'
                                              : 'rps');
                                      await roomHandler.dispose();

                                      if (context.mounted) {
                                        setState(() {
                                          _isCreatingRoom = false;
                                        });
                                        AppLogger.info('Navigating to waiting room: $roomCode',
                                            tag: 'OpponentSelector');
                                        context.push('${AppRoutes.waitingRoom}?roomCode=$roomCode');
                                      }
                                    } catch (e) {
                                      AppLogger.error('Failed to create room: $e',
                                          tag: 'OpponentSelector', error: e);
                                      if (context.mounted) {
                                        setState(() {
                                          _isCreatingRoom = false;
                                        });
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text('Failed to create room: $e'),
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
        ),
      ),
    );
  }

  @override
  void dispose() {
    AppLogger.info('Disposing OpponentSelector', tag: 'OpponentSelector');
    super.dispose();
  }

  Widget _buildOpponentButton(
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
