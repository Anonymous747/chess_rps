import 'package:chess_rps/common/enum.dart';
import 'package:chess_rps/data/service/game/classical_game_strategy.dart';
import 'package:chess_rps/data/service/game/rps_game_strategy.dart';
import 'package:chess_rps/domain/model/cell.dart';
import 'package:chess_rps/presentation/controller/game_controller.dart';
import 'package:chess_rps/presentation/mediator/game_mode_mediator.dart';
import 'package:chess_rps/presentation/mediator/player_side_mediator.dart';
import 'package:chess_rps/presentation/state/game_state.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:riverpod/riverpod.dart';

part 'game_strategy.g.dart';

@riverpod
GameStrategy gameStrategy(Ref ref) {
  switch (GameModesMediator.gameMode) {
    case GameMode.classical:
      return ClassicalGameStrategy();
    case GameMode.rps:
      return RpsGameStrategy();
  }
}

abstract class GameStrategy {
  Future<void> initialAction(GameController controller, GameState state);

  Future<void> onPressed(
      GameController controller, GameState state, Cell pressedCell) async {
    final currentOrder = state.currentOrder;

    if (state.selectedFigure != null &&
        (pressedCell.isAvailable || pressedCell.canBeKnockedDown)) {
      await makeMove(controller, pressedCell);
    }

    if (pressedCell.isOccupied &&
        pressedCell.figureSide == currentOrder &&
        pressedCell.figure!.side == PlayerSideMediator.playerSide) {
      controller.showAvailableActions(pressedCell);
      controller.ref.notifyListeners();
    }
  }

  Future<bool> makeMove(GameController controller, Cell pressedCell) async {
    return await controller.makeMove(pressedCell);
  }
}
