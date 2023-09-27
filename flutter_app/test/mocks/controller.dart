import 'package:chess_rps/domain/model/board.dart';
import 'package:chess_rps/domain/model/cell.dart';
import 'package:chess_rps/presentation/controller/game_controller.dart';
import 'package:chess_rps/presentation/state/game_state.dart';

class GameControllerMock extends GameController {
  @override
  GameState build() {
    final board = Board()..startGame();
    final state = GameState(board: board);

    return state;
  }

  @override
  void makeMove(Cell target) {
    state = state.copyWith(selectedFigure: '6-4');

    super.makeMove(target);
  }
}
