import 'package:chess_rps/common/enum.dart';
import 'package:chess_rps/common/logger.dart';
import 'package:chess_rps/domain/model/cell.dart';
import 'package:chess_rps/domain/service/game_strategy.dart';
import 'package:chess_rps/presentation/controller/game_controller.dart';
import 'package:chess_rps/presentation/mediator/game_mode_mediator.dart';
import 'package:chess_rps/presentation/mediator/player_side_mediator.dart';
import 'package:chess_rps/presentation/state/game_state.dart';

class ClassicalGameStrategy extends GameStrategy {
  @override
  Future<void> initialAction(GameController controller, GameState state) async {
    AppLogger.info(
        'ClassicalGameStrategy.initialAction - Player side: ${PlayerSideMediator.playerSide}, Current order: ${state.currentOrder}',
        tag: 'ClassicalGameStrategy');
    // For online games, don't trigger opponent move here - wait for WebSocket messages
    // Only for AI games, trigger initial move if player is dark
    final opponentMode = GameModesMediator.opponentMode;
    if (opponentMode == OpponentMode.ai && !PlayerSideMediator.playerSide.isLight) {
      AppLogger.info('Player is dark in AI game, triggering initial AI move',
          tag: 'ClassicalGameStrategy');
      // Retry the initial AI move up to 2 times if it fails (e.g., due to Stockfish initialization issues)
      bool moveSucceeded = false;
      for (int attempt = 1; attempt <= 2 && !moveSucceeded; attempt++) {
        if (attempt > 1) {
          AppLogger.info('Retrying initial AI move (attempt $attempt/2)', tag: 'ClassicalGameStrategy');
          // Wait a bit before retrying to allow Stockfish to initialize
          await Future.delayed(const Duration(milliseconds: 500));
        }
        moveSucceeded = await controller.makeOpponentsMove();
        if (moveSucceeded) {
          AppLogger.info('Initial AI move succeeded on attempt $attempt', tag: 'ClassicalGameStrategy');
        } else {
          AppLogger.warning('Initial AI move failed on attempt $attempt', tag: 'ClassicalGameStrategy');
        }
      }
      if (!moveSucceeded) {
        AppLogger.error('Initial AI move failed after 2 attempts. Game may be stuck.', tag: 'ClassicalGameStrategy');
      }
    } else {
      AppLogger.info('Player is light or online game, waiting for player/opponent move',
          tag: 'ClassicalGameStrategy');
    }
  }

  @override
  Future<void> onPressed(GameController controller, GameState state, Cell pressedCell) async {
    await super.onPressed(controller, state, pressedCell);
  }

  @override
  Future<bool> makeMove(GameController controller, Cell pressedCell) async {
    final currentState = controller.currentState;
    AppLogger.info(
        'ClassicalGameStrategy.makeMove - Player move: ${pressedCell.position.row},${pressedCell.position.col}, Current order before move: ${currentState.currentOrder}',
        tag: 'ClassicalGameStrategy');

    final isMoved = await super.makeMove(controller, pressedCell);

    if (!isMoved) {
      AppLogger.warning('Player move failed, not triggering AI move', tag: 'ClassicalGameStrategy');
      return false;
    }

    final stateAfterMove = controller.currentState;
    AppLogger.info(
        'Player move successful. Current order after move: ${stateAfterMove.currentOrder}',
        tag: 'ClassicalGameStrategy');

    // Note: AI moves are automatically triggered by _makeMoveViaAction() in GameController
    // after player moves, so we don't need to call makeOpponentsMove() here.
    // This prevents duplicate AI move triggers.
    // For online games, opponent moves come via WebSocket listener.

    return true;
  }
}
