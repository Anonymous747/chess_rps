import 'package:chess_rps/common/enum.dart';
import 'package:chess_rps/common/logger.dart';
import 'package:chess_rps/common/palette.dart';
import 'package:chess_rps/presentation/controller/game_controller.dart';
import 'package:chess_rps/presentation/utils/app_router.dart';
import 'package:chess_rps/presentation/widget/board_widget.dart';
import 'package:chess_rps/presentation/widget/captured_pieces_widget.dart';
import 'package:chess_rps/presentation/widget/game_over_dialog.dart';
import 'package:chess_rps/presentation/widget/move_history_widget.dart';
import 'package:chess_rps/presentation/widget/rps_overlay.dart';
import 'package:chess_rps/presentation/widget/timer_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class ChessScreen extends HookConsumerWidget {
  static const routeName = '/Chess';

  const ChessScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(gameControllerProvider.notifier);
    final board = ref.watch(gameControllerProvider.select((state) => state.board));
    final showRpsOverlay = ref.read(gameControllerProvider.select((state) => state.showRpsOverlay));
    final waitingForRpsResult =
        ref.read(gameControllerProvider.select((state) => state.waitingForRpsResult));
    final opponentRpsChoice =
        ref.read(gameControllerProvider.select((state) => state.opponentRpsChoice));
    final playerWonRps = ref.read(gameControllerProvider.select((state) => state.playerWonRps));
    final lightPlayerTime =
        ref.watch(gameControllerProvider.select((state) => state.lightPlayerTimeSeconds));
    final darkPlayerTime =
        ref.watch(gameControllerProvider.select((state) => state.darkPlayerTimeSeconds));
    final currentOrder = ref.watch(gameControllerProvider.select((state) => state.currentOrder));
    final playerSide = ref.watch(gameControllerProvider.select((state) => state.playerSide));
    final moveHistory = ref.watch(gameControllerProvider.select((state) => state.moveHistory));
    
    // Watch for game over state
    final gameOver = ref.watch(gameControllerProvider.select((state) => state.gameOver));
    final winner = ref.watch(gameControllerProvider.select((state) => state.winner));
    final isCheckmate = ref.watch(gameControllerProvider.select((state) => state.isCheckmate));
    final isStalemate = ref.watch(gameControllerProvider.select((state) => state.isStalemate));
    
    // Track if dialog has been shown to prevent multiple showings
    final dialogShown = useRef(false);
    
    // Show game over dialog when game ends (only once)
    useEffect(() {
      if (gameOver && !dialogShown.value && context.mounted) {
        dialogShown.value = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (context.mounted) {
            _showGameOverDialog(
              context,
              controller,
              winner: winner,
              playerSide: playerSide,
              isCheckmate: isCheckmate,
              isStalemate: isStalemate,
            );
          }
        });
      }
      return null;
    }, [gameOver, winner, playerSide, isCheckmate, isStalemate]);

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
              SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                  // Top bar with finish button and timers in one row
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                    child: Column(
                      children: [
                        // Status text row
                        Center(
                          child: _buildStatusText(playerWonRps),
                        ),
                        const SizedBox(height: 12),
                        // Row with finish button and timers
                        Row(
                          children: [
                            // Finish game button
                            Container(
                              decoration: BoxDecoration(
                                color: Palette.backgroundTertiary,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Palette.glassBorder,
                                  width: 1,
                                ),
                              ),
                              child: TextButton(
                                onPressed: () => _showFinishGameDialog(context, controller),
                                child: Text(
                                  'Завершить игру',
                                  style: TextStyle(
                                    color: Palette.textPrimary,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            // Timer widget
                            Expanded(
                              child: TimerWidget(
                                lightPlayerTimeSeconds: lightPlayerTime,
                                darkPlayerTimeSeconds: darkPlayerTime,
                                currentTurn: currentOrder,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Opponent's captured pieces (above board)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Opponent\'s Captures',
                          style: TextStyle(
                            color: Palette.textSecondary,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        CapturedPiecesWidget(
                          board: board,
                          isLightSide: !playerSide.isLight,
                        ),
                      ],
                    ),
                  ),
                  // Board area
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: BoardWidget(board: board),
                    ),
                  ),
                  // Player's captured pieces (below board)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Your Captures',
                          style: TextStyle(
                            color: Palette.textSecondary,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        CapturedPiecesWidget(
                          board: board,
                          isLightSide: playerSide.isLight,
                        ),
                      ],
                    ),
                  ),
                  // Move history at the bottom
                  Container(
                    height: 200,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    child: MoveHistoryWidget(
                      moveHistory: moveHistory,
                      board: board,
                    ),
                  ),
                  ],
                ),
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
      return const SizedBox();
    }
  }

  void _showFinishGameDialog(BuildContext context, GameController controller) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: Palette.backgroundTertiary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: Palette.glassBorder,
              width: 1,
            ),
          ),
          title: Text(
            'Завершить игру?',
            style: TextStyle(
              color: Palette.textPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          content: Text(
            'Вы действительно хотите завершить игру? Результат будет потерян.',
            style: TextStyle(
              color: Palette.textSecondary,
              fontSize: 14,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: Text(
                'Нет',
                style: TextStyle(
                  color: Palette.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                controller.dispose();
                context.pop();
              },
              child: Text(
                'Да',
                style: TextStyle(
                  color: Palette.error,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showGameOverDialog(
    BuildContext context,
    GameController controller, {
    required Side? winner,
    required Side playerSide,
    required bool isCheckmate,
    required bool isStalemate,
  }) {
    // Prevent showing dialog multiple times
    if (!context.mounted) return;
    
    showDialog(
      context: context,
      barrierDismissible: false, // Prevent dismissing by tapping outside
      builder: (BuildContext dialogContext) {
        return GameOverDialog(
          winner: winner,
          playerSide: playerSide,
          isCheckmate: isCheckmate,
          isStalemate: isStalemate,
          onReturnToMenu: () {
            _handleGameOver(context, controller, winner, playerSide, isCheckmate, isStalemate);
          },
        );
      },
    );
  }

  void _handleGameOver(
    BuildContext context,
    GameController controller,
    Side? winner,
    Side playerSide,
    bool isCheckmate,
    bool isStalemate,
  ) {
    // Log analytics
    final playerWon = winner == playerSide;
    final isDraw = isStalemate || winner == null;
    
    AppLogger.info(
      'Game Over Analytics:',
      tag: 'ChessScreen',
    );
    AppLogger.info(
      '  - Result: ${isDraw ? "Draw" : (playerWon ? "Win" : "Loss")}',
      tag: 'ChessScreen',
    );
    AppLogger.info(
      '  - End Type: ${isCheckmate ? "Checkmate" : (isStalemate ? "Stalemate" : "Other")}',
      tag: 'ChessScreen',
    );
    AppLogger.info(
      '  - Player Side: ${playerSide.name}',
      tag: 'ChessScreen',
    );
    AppLogger.info(
      '  - Winner: ${winner?.name ?? "None"}',
      tag: 'ChessScreen',
    );
    
    // TODO: Send analytics to backend when analytics service is implemented
    // Example:
    // await analyticsService.recordGameResult(
    //   result: isDraw ? GameResult.draw : (playerWon ? GameResult.win : GameResult.loss),
    //   endType: isCheckmate ? GameEndType.checkmate : (isStalemate ? GameEndType.stalemate : GameEndType.other),
    //   playerSide: playerSide,
    // );
    
    // Dispose controller and navigate to main menu
    controller.dispose();
    if (context.mounted) {
      context.go(AppRoutes.mainMenu);
    }
  }
}
