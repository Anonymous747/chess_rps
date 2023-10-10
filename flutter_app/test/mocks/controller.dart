import 'package:chess_rps/domain/model/board.dart';
import 'package:chess_rps/domain/model/cell.dart';
import 'package:chess_rps/domain/service/logger.dart';
import 'package:chess_rps/presentation/controller/game_controller.dart';
import 'package:chess_rps/presentation/state/game_state.dart';
import 'package:mockito/mockito.dart';
import 'package:stockfish_interpreter/stockfish/stockfish_interpreter.dart';

class GameControllerMock extends GameController with Mock {
  @override
  GameState build() {
    stockfishInterpreter = StockfishInterpreter(
      parameters: {},
      isTestFlow: true,
    );

    final board = Board()..startGame();
    final state = GameState(board: board);

    return state;
  }

  @override
  void makeMove(Cell target, {Cell? from}) {
    state = state.copyWith(selectedFigure: '6-4');

    super.makeMove(target, from: from);
  }
}

class LoggerProviderMock extends Mock implements Logger {}
