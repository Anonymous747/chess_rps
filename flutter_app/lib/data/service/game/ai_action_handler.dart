import 'package:chess_rps/domain/service/action_handler.dart';
import 'package:stockfish_interpreter/stockfish_interpreter.dart';

class AIActionHandler extends ActionHandler {
  late final StockfishInterpreter _stockfishInterpreter;

  AIActionHandler(this._stockfishInterpreter);

  @override
  Future<String?> getOpponentsMove() async {
    await _stockfishInterpreter.visualizeBoard();
    return await _stockfishInterpreter.getBestMove();
  }

  @override
  Future<void> makeMove(String action) async {
    try {
      await _stockfishInterpreter.makeMovesFromCurrentPosition([action]);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> visualizeBoard() async {
    await _stockfishInterpreter.visualizeBoard();
  }

  @override
  void dispose() {
    _stockfishInterpreter.disposeEngine();
  }
}
