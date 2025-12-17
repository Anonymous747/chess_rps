import 'package:chess_rps/common/palette.dart';
import 'package:chess_rps/presentation/controller/game_controller.dart';
import 'package:chess_rps/presentation/widget/board_widget.dart';
import 'package:chess_rps/presentation/widget/rps_overlay.dart';
import 'package:chess_rps/presentation/widget/timer_widget.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class ChessScreen extends HookConsumerWidget {
  static const routeName = '/Chess';

  const ChessScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(gameControllerProvider.notifier);
    final board =
        ref.read(gameControllerProvider.select((state) => state.board));
    final showRpsOverlay =
        ref.read(gameControllerProvider.select((state) => state.showRpsOverlay));
    final waitingForRpsResult = ref.read(
        gameControllerProvider.select((state) => state.waitingForRpsResult));
    final opponentRpsChoice = ref.read(
        gameControllerProvider.select((state) => state.opponentRpsChoice));
    final playerWonRps =
        ref.read(gameControllerProvider.select((state) => state.playerWonRps));
    final lightPlayerTime = ref.watch(
        gameControllerProvider.select((state) => state.lightPlayerTimeSeconds));
    final darkPlayerTime = ref.watch(
        gameControllerProvider.select((state) => state.darkPlayerTimeSeconds));
    final currentOrder = ref.watch(
        gameControllerProvider.select((state) => state.currentOrder));

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Palette.background,
              Palette.backgroundSecondary,
              Palette.backgroundTertiary,
            ],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Top bar with back button, timer, and status
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                    child: Column(
                      children: [
                        Row(
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
                                icon: const Icon(
                                  Icons.arrow_back,
                                  color: Palette.textPrimary,
                                ),
                              onPressed: () {
                                controller.dispose();
                                context.pop();
                              },
                              ),
                            ),
                            Expanded(
                              child: Center(
                                child: _buildStatusText(playerWonRps),
                              ),
                            ),
                            const SizedBox(width: 56), // Balance for back button
                          ],
                        ),
                        const SizedBox(height: 12),
                        // Timer widget
                        TimerWidget(
                          lightPlayerTimeSeconds: lightPlayerTime,
                          darkPlayerTimeSeconds: darkPlayerTime,
                          currentTurn: currentOrder,
                        ),
                      ],
                    ),
                  ),
                  // Board area
                  Expanded(
                    flex: 3,
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: BoardWidget(board: board),
                      ),
                    ),
                  ),
                  // Bottom area
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 14,
                            ),
                            decoration: BoxDecoration(
                              color: Palette.backgroundTertiary,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Palette.glassBorder,
                                width: 1,
                              ),
                            ),
                            child: TextButton(
                              onPressed: () async {
                                await controller.executeCommand();
                              },
                              child: Text(
                                'Debug: Visualize Board',
                                style: TextStyle(
                                  color: Palette.textSecondary,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              if (showRpsOverlay)
                RpsOverlay(
                  onChoiceSelected: (choice) async {
                    await controller.handleRpsChoice(choice);
                  },
                  isWaitingForOpponent: waitingForRpsResult,
                  opponentChoice: opponentRpsChoice?.displayName,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusText(bool? playerWonRps) {
    if (playerWonRps == true) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: Palette.success.withOpacity(0.2),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Palette.success.withOpacity(0.5),
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.check_circle_outline,
              size: 18,
              color: Palette.success,
            ),
            const SizedBox(width: 8),
            Text(
              'You won RPS! Make your move',
              style: TextStyle(
                color: Palette.success,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    } else if (playerWonRps == false) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: Palette.warning.withOpacity(0.2),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Palette.warning.withOpacity(0.5),
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.hourglass_empty,
              size: 18,
              color: Palette.warning,
            ),
            const SizedBox(width: 8),
            Text(
              'Opponent won RPS. Waiting...',
              style: TextStyle(
                color: Palette.warning,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    } else {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: Palette.backgroundTertiary,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Palette.glassBorder,
            width: 1,
          ),
        ),
        child: Text(
          'Chess Game',
          style: TextStyle(
            color: Palette.textPrimary,
            fontWeight: FontWeight.w600,
            fontSize: 16,
            letterSpacing: 0.5,
          ),
        ),
      );
    }
  }
}
