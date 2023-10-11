import 'package:chess_rps/domain/model/board.dart';
import 'package:chess_rps/domain/model/cell.dart';
import 'package:chess_rps/domain/service/action_handler.dart';
import 'package:chess_rps/domain/service/logger.dart';
import 'package:chess_rps/presentation/controller/game_controller.dart';
import 'package:chess_rps/presentation/state/game_state.dart';
import 'package:mockito/mockito.dart';
import 'package:stockfish_interpreter/stockfish/stockfish_interpreter.dart';

class GameControllerMock extends GameController with Mock {
  @override
  GameState build() {
    this.actionHandler = ActionHandlerMock();
    actionLogger = LoggerProviderMock();

    final board = Board()..startGame();
    final state = GameState(board: board);

    return state;
  }

  @override
  void makeMove(Cell target, {Cell? from}) {
    super.makeMove(target, from: from);
  }
}

class LoggerProviderMock extends Logger with Mock {}

class StockfishInterpreterMock extends StockfishInterpreter with Mock {
  StockfishInterpreterMock() : super(parameters: {}, isTestFlow: true);
}

class ActionHandlerMock extends ActionHandler with Mock {}
