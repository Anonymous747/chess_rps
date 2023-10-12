import 'package:chess_rps/common/enum.dart';
import 'package:chess_rps/data/service/game/classical_game_service.dart';
import 'package:chess_rps/data/service/game/rps_game_service.dart';
import 'package:chess_rps/domain/model/cell.dart';
import 'package:chess_rps/presentation/controller/game_controller.dart';
import 'package:chess_rps/presentation/mediator/game_mode_mediator.dart';
import 'package:chess_rps/presentation/mediator/player_side_mediator.dart';
import 'package:chess_rps/presentation/state/game_state.dart';
import 'package:flutter/cupertino.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'game_service.g.dart';

@riverpod
GameService gameHandler(GameHandlerRef ref) {
  final controller = ref.read(gameControllerProvider.notifier);

  switch (GameModesMediator.gameMode) {
    case GameMode.classical:
      return ClassicalGameService(controller);
    case GameMode.rps:
      return RpsGameService(controller);
  }
}

abstract class GameService {
  @protected
  final GameController controller;

  GameService(this.controller);

  GameState? get state => controller.currentState;
  bool get isUsersMove => state?.currentOrder == PlayerSideMediator.playerSide;

  Future<void> initialAction();

  Future<void> onPressed(Cell pressedCell) async {
    if (state == null) return;

    final currentOrder = state!.currentOrder;

    if (state?.selectedFigure != null &&
        (pressedCell.isAvailable || pressedCell.canBeKnockedDown)) {
      await controller.makeMove(pressedCell);
    }

    if (pressedCell.isOccupied &&
        pressedCell.figureSide == currentOrder &&
        pressedCell.figure!.side == PlayerSideMediator.playerSide) {
      controller.showAvailableActions(pressedCell);
      controller.ref.notifyListeners();
    }
  }

  Future<void> executeCommand() async {
    controller.executeCommand();
  }

  void dispose() {
    controller.dispose();
  }
}
