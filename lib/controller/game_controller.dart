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

  void showAvailableActions(Cell fromCell) {
    if (state.isFigureSelected) {
      state.board.removeSelection();
    }

    final availableHashes =
        ActionChecker.getAvailablePositionsHash(state.board, fromCell);

    final fromRow = fromCell.position.row;
    final fromCol = fromCell.position.col;

    if (fromCell.isSelected) {
      state.board.removeSelection();
    } else {
      for (final hash in availableHashes) {
        final position = hash.toPosition();
        final row = position.row;
        final col = position.col;

        state.board.cells[row][col] =
            state.board.cells[row][col].copyWith(isAvailable: true);
        state = state.copyWith(isFigureSelected: true);
      }
    }

    state.board.cells[fromRow][fromCol] =
        fromCell.copyWith(isSelected: !fromCell.isSelected);

    ref.notifyListeners();
  }
}
