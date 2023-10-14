import 'package:chess_rps/common/extension.dart';
import 'package:chess_rps/domain/service/action_handler.dart';
import 'package:stockfish_interpreter/stockfish_interpreter.dart';

class AIActionHandler extends ActionHandler {
  late final StockfishInterpreter _stockfishInterpreter;

  AIActionHandler(this._stockfishInterpreter);

  @override
  Future<String?> getOpponentsMove() async {
    await _stockfishInterpreter.visualizeBoard();
    final bestMove = await _stockfishInterpreter.getBestMove();

    if (bestMove.isNullOrEmpty) return null;

    return bestMove!.split(" ")[1];
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
  Future<void> dispose() async {
    _stockfishInterpreter.disposeEngine();
  }
}
