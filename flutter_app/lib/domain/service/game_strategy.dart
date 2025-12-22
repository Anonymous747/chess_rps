import 'package:chess_rps/common/enum.dart';
import 'package:chess_rps/common/logger.dart';
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
    
    AppLogger.info(
      '=== GameStrategy.onPressed START ===',
      tag: 'GameStrategy'
    );
    // Use positionHash for logging (format: "row-col")
    AppLogger.info(
      'Pressed cell: ${pressedCell.positionHash} (row=${pressedCell.position.row}, col=${pressedCell.position.col})',
      tag: 'GameStrategy'
    );
    AppLogger.info(
      'Pressed cell isOccupied: ${pressedCell.isOccupied}, '
      'figureSide: ${pressedCell.figureSide}, '
      'figureRole: ${pressedCell.figure?.role}',
      tag: 'GameStrategy'
    );
    AppLogger.info(
      'Pressed cell isAvailable: ${pressedCell.isAvailable}, '
      'canBeKnockedDown: ${pressedCell.canBeKnockedDown}',
      tag: 'GameStrategy'
    );
    AppLogger.info(
      'Current selectedFigure: ${state.selectedFigure}, '
      'currentOrder: ${currentOrder}, '
      'playerSide: ${PlayerSideMediator.playerSide}',
      tag: 'GameStrategy'
    );

    // First check if the pressed cell is a piece of the current player
    // If so, select it (this will clear any previous selection)
    if (pressedCell.isOccupied &&
        pressedCell.figureSide == currentOrder &&
        pressedCell.figure!.side == PlayerSideMediator.playerSide) {
      AppLogger.info(
        'Pressed cell is own piece - selecting it and clearing previous selection',
        tag: 'GameStrategy'
      );
      controller.showAvailableActions(pressedCell);
      controller.ref.notifyListeners();
      AppLogger.info(
        '=== GameStrategy.onPressed END (piece selected) ===',
        tag: 'GameStrategy'
      );
      return; // Don't process as a move if selecting a new piece
    }

    // Only try to make a move if we have a selected piece and the target is valid
    // CRITICAL: Never make a move if the target cell contains our own piece
    if (state.selectedFigure != null &&
        (pressedCell.isAvailable || pressedCell.canBeKnockedDown)) {
      // Double-check: if target cell has our own piece, don't move
      if (pressedCell.isOccupied &&
          pressedCell.figureSide == currentOrder &&
          pressedCell.figure!.side == PlayerSideMediator.playerSide) {
        AppLogger.warning(
          'BLOCKED MOVE ATTEMPT: Target cell contains own piece! '
          'selectedFigure=${state.selectedFigure} -> ${pressedCell.positionHash}, '
          'targetPiece=${pressedCell.figure?.role}',
          tag: 'GameStrategy'
        );
        AppLogger.info(
          '=== GameStrategy.onPressed END (move blocked - own piece) ===',
          tag: 'GameStrategy'
        );
        return; // Don't make the move
      }
      
      AppLogger.info(
        'Attempting to make move: selectedFigure=${state.selectedFigure} -> ${pressedCell.positionHash}',
        tag: 'GameStrategy'
      );
      await makeMove(controller, pressedCell);
      AppLogger.info(
        '=== GameStrategy.onPressed END (move attempted) ===',
        tag: 'GameStrategy'
      );
    } else {
      AppLogger.info(
        'No action taken: selectedFigure=${state.selectedFigure}, '
        'isAvailable=${pressedCell.isAvailable}, '
        'canBeKnockedDown=${pressedCell.canBeKnockedDown}',
        tag: 'GameStrategy'
      );
      AppLogger.info(
        '=== GameStrategy.onPressed END (no action) ===',
        tag: 'GameStrategy'
      );
    }
  }

  Future<bool> makeMove(GameController controller, Cell pressedCell) async {
    return await controller.makeMove(pressedCell);
  }
}
