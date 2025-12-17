import 'package:chess_rps/domain/model/cell.dart';
import 'package:chess_rps/domain/service/game_strategy.dart';
import 'package:chess_rps/presentation/controller/game_controller.dart';
import 'package:chess_rps/presentation/mediator/player_side_mediator.dart';
import 'package:chess_rps/presentation/state/game_state.dart';
import 'package:flutter/foundation.dart';

class ClassicalGameStrategy extends GameStrategy {
  @override
  Future<void> initialAction(GameController controller, GameState state) async {
    if (!PlayerSideMediator.playerSide.isLight) {
      await controller.makeOpponentsMove();
    }
  }

  @override
  Future<void> onPressed(
      GameController controller, GameState state, Cell pressedCell) async {
    await super.onPressed(controller, state, pressedCell);
  }

  @override
  Future<bool> makeMove(GameController controller, Cell pressedCell) async {
    final isMoved = await super.makeMove(controller, pressedCell);

    if (!isMoved) return false;

    // Trigger AI move after player's move
    // Don't await to avoid blocking, but handle errors
    controller.makeOpponentsMove().then((aiMoved) {
      if (!aiMoved) {
        debugPrint('AI failed to make a move');
      }
    }).catchError((error) {
      debugPrint('AI move error: $error');
    });

    return true;
  }
}
