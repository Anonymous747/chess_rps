import 'package:chess_rps/domain/model/cell.dart';
import 'package:chess_rps/domain/service/game_strategy.dart';
import 'package:chess_rps/presentation/controller/game_controller.dart';
import 'package:chess_rps/presentation/mediator/player_side_mediator.dart';
import 'package:chess_rps/presentation/state/game_state.dart';

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

    return await controller.makeOpponentsMove();
  }
}
