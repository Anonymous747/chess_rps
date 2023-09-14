import 'package:chess_rps/common/extension.dart';
import 'package:chess_rps/model/board.dart';
import 'package:chess_rps/model/cell.dart';
import 'package:chess_rps/state/game_state.dart';
import 'package:chess_rps/utils/action_checker.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'game_controller.g.dart';

@riverpod
class GameController extends _$GameController {
  @override
  GameState build() {
    final board = Board()..startGame();
    final state = GameState(board: board);

    return state;
  }

  void _displayAvailableCells(Cell fromCell) {
    final availableHashes =
        ActionChecker.getAvailablePositionsHash(state.board, fromCell);

    for (final hash in availableHashes) {
      final position = hash.toPosition();
      final row = position.row;
      final col = position.col;
      final target = state.board.cells[row][col];

      final canBeKnockedDown = target.isOccupied &&
          fromCell.figure != null &&
          target.figure != null &&
          fromCell.figure?.side != target.figure?.side;

      // Opposite figure available to knock
      if (canBeKnockedDown) {
        state.board.cells[row][col] =
            state.board.cells[row][col].copyWith(canBeKnockedDown: true);
      } else {
        state.board.cells[row][col] =
            state.board.cells[row][col].copyWith(isAvailable: true);
      }
    }
  }

  void showAvailableActions(Cell fromCell) {
    if (state.selectedFigure != null) {
      state = state.copyWith(selectedFigure: null);
      state.board.removeSelection();
    }

    if (!fromCell.isSelected) {
      _displayAvailableCells(fromCell);
    }

    final fromRow = fromCell.position.row;
    final fromCol = fromCell.position.col;

    state.board.cells[fromRow][fromCol] =
        fromCell.copyWith(isSelected: !fromCell.isSelected);
    state = state.copyWith(selectedFigure: fromCell.positionHash);

    ref.notifyListeners();
  }
}