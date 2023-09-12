import 'package:chess_rps/common/extension.dart';
import 'package:chess_rps/model/board.dart';
import 'package:chess_rps/model/cell.dart';
import 'package:chess_rps/utils/action_checker.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'game_controller.g.dart';

@riverpod
class GameController extends _$GameController {
  @override
  Board build() {
    final board = Board()..startGame();

    return board;
  }

  void showAvailableActions(Cell fromCell) {
    final availableHashes =
        ActionChecker.getAvailablePositionsHash(state, fromCell);

    for (final hash in availableHashes) {
      final position = hash.toPosition();
      final row = position.row;
      final col = position.col;

      state.cells[row][col] = state.cells[row][col].copyWith(isSelected: true);
    }

    ref.notifyListeners();
  }
}
