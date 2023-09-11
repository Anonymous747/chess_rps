import 'package:chess_rps/model/board.dart';
import 'package:chess_rps/model/cell.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'game_controller.g.dart';

@riverpod
class GameController extends _$GameController {
  @override
  Board build() {
    final board = Board()..startGame();

    return board;
  }

  void showAvailableActions(Cell cell) {
    // ActionChecker.isVerticalActionAvailable(, from, to)

    ref.notifyListeners();
  }
}
