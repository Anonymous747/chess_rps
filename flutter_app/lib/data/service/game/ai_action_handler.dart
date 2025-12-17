import 'package:chess_rps/common/extension.dart';
import 'package:chess_rps/common/logger.dart';
import 'package:chess_rps/domain/service/action_handler.dart';
import 'package:stockfish_interpreter/stockfish_interpreter.dart';

class AIActionHandler extends ActionHandler {
  late final StockfishInterpreter _stockfishInterpreter;

  AIActionHandler(this._stockfishInterpreter);

  @override
  Future<String?> getOpponentsMove() async {
    AppLogger.info('Getting AI opponent move', tag: 'AIActionHandler');
    try {
      // Visualize board to sync state (optional but helps with debugging)
      AppLogger.debug('Visualizing board in Stockfish', tag: 'AIActionHandler');
      await _stockfishInterpreter.visualizeBoard();
      
      // Get the best move from Stockfish
      AppLogger.debug('Requesting best move from Stockfish', tag: 'AIActionHandler');
      final bestMove = await _stockfishInterpreter.getBestMove();

      if (bestMove.isNullOrEmpty) {
        AppLogger.warning('Stockfish returned no move', tag: 'AIActionHandler');
        return null;
      }

      // Extract move from "bestmove e2e4" format
      final moveParts = bestMove!.split(" ");
      if (moveParts.length < 2) {
        AppLogger.warning('Invalid move format from Stockfish: $bestMove', tag: 'AIActionHandler');
        return null;
      }

      final move = moveParts[1];
      AppLogger.info('AI move determined: $move', tag: 'AIActionHandler');
      return move;
    } catch (e) {
      AppLogger.error('Error getting AI move: $e', tag: 'AIActionHandler', error: e);
      return null;
    }
  }

  @override
  Future<void> makeMove(String action) async {
    AppLogger.info('Making move in Stockfish: $action', tag: 'AIActionHandler');
    try {
      await _stockfishInterpreter.makeMovesFromCurrentPosition([action]);
      AppLogger.debug('Move applied successfully in Stockfish', tag: 'AIActionHandler');
    } catch (e) {
      AppLogger.error('Error making move in Stockfish: $e', tag: 'AIActionHandler', error: e);
      rethrow;
    }
  }

  @override
  Future<void> visualizeBoard() async {
    await _stockfishInterpreter.visualizeBoard();
  }

  @override
  Future<void> dispose() async {
    AppLogger.info('Disposing AIActionHandler', tag: 'AIActionHandler');
    _stockfishInterpreter.disposeEngine();
    AppLogger.debug('AIActionHandler disposed', tag: 'AIActionHandler');
  }
}
