import 'package:chess_rps/common/enum.dart';
import 'package:chess_rps/common/logger.dart';
import 'package:chess_rps/domain/model/cell.dart';
import 'package:chess_rps/domain/service/game_strategy.dart';
import 'package:chess_rps/presentation/controller/game_controller.dart';
import 'package:chess_rps/presentation/mediator/game_mode_mediator.dart';
import 'package:chess_rps/presentation/mediator/player_side_mediator.dart';
import 'package:chess_rps/presentation/state/game_state.dart';
import 'package:flutter/foundation.dart';

class ClassicalGameStrategy extends GameStrategy {
  @override
  Future<void> initialAction(GameController controller, GameState state) async {
    AppLogger.info(
      'ClassicalGameStrategy.initialAction - Player side: ${PlayerSideMediator.playerSide}, Current order: ${state.currentOrder}',
      tag: 'ClassicalGameStrategy'
    );
    // For online games, don't trigger opponent move here - wait for WebSocket messages
    // Only for AI games, trigger initial move if player is dark
    final opponentMode = GameModesMediator.opponentMode;
    if (opponentMode == OpponentMode.ai && !PlayerSideMediator.playerSide.isLight) {
      AppLogger.info('Player is dark in AI game, triggering initial AI move', tag: 'ClassicalGameStrategy');
      await controller.makeOpponentsMove();
    } else {
      AppLogger.info('Player is light or online game, waiting for player/opponent move', tag: 'ClassicalGameStrategy');
    }
  }

  @override
  Future<void> onPressed(
      GameController controller, GameState state, Cell pressedCell) async {
    await super.onPressed(controller, state, pressedCell);
  }

  @override
  Future<bool> makeMove(GameController controller, Cell pressedCell) async {
    final currentState = controller.currentState;
    AppLogger.info(
      'ClassicalGameStrategy.makeMove - Player move: ${pressedCell.position.row},${pressedCell.position.col}, Current order before move: ${currentState.currentOrder}',
      tag: 'ClassicalGameStrategy'
    );
    
    final isMoved = await super.makeMove(controller, pressedCell);

    if (!isMoved) {
      AppLogger.warning('Player move failed, not triggering AI move', tag: 'ClassicalGameStrategy');
      return false;
    }

    final stateAfterMove = controller.currentState;
    AppLogger.info(
      'Player move successful. Current order after move: ${stateAfterMove.currentOrder}',
      tag: 'ClassicalGameStrategy'
    );

    // For online games, don't call makeOpponentsMove() - WebSocket listener handles opponent moves
    // For AI games, trigger AI move after player's move
    final opponentMode = GameModesMediator.opponentMode;
    if (opponentMode == OpponentMode.ai) {
      AppLogger.info('AI game - triggering AI move', tag: 'ClassicalGameStrategy');
      // Trigger AI move after player's move
      // Await to ensure the move is fully processed before continuing
      try {
        AppLogger.info('Calling makeOpponentsMove()...', tag: 'ClassicalGameStrategy');
        final aiMoved = await controller.makeOpponentsMove();
        if (!aiMoved) {
          AppLogger.warning('AI failed to make a move', tag: 'ClassicalGameStrategy');
          debugPrint('AI failed to make a move');
        } else {
          AppLogger.info('AI move completed successfully', tag: 'ClassicalGameStrategy');
        }
      } catch (error, stackTrace) {
        AppLogger.error('AI move error: $error', tag: 'ClassicalGameStrategy', error: error, stackTrace: stackTrace);
        debugPrint('AI move error: $error');
      }
    } else {
      AppLogger.info('Online game - waiting for opponent move via WebSocket', tag: 'ClassicalGameStrategy');
    }

    return true;
  }
}
