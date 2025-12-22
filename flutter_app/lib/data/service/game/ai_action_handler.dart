import 'package:chess_rps/common/extension.dart';
import 'package:chess_rps/common/logger.dart';
import 'package:chess_rps/domain/service/action_handler.dart';
import 'package:stockfish_interpreter/stockfish_interpreter.dart';

class AIActionHandler extends ActionHandler {
  late final StockfishInterpreter _stockfishInterpreter;

  AIActionHandler(this._stockfishInterpreter);

  @override
  Future<String?> getOpponentsMove() async {
    AppLogger.info('=== AIActionHandler.getOpponentsMove() START ===', tag: 'AIActionHandler');
    try {
      // Check Stockfish state
      AppLogger.info('Stockfish state: ${_stockfishInterpreter.state}', tag: 'AIActionHandler');
      AppLogger.info('Stockfish is ready: ${_stockfishInterpreter.state == "ready"}', tag: 'AIActionHandler');
      
      // Check Stockfish state and wait if needed
      final currentState = _stockfishInterpreter.state;
      AppLogger.info('Stockfish state before wait: $currentState', tag: 'AIActionHandler');
      
      // If disposed, this is an error - Stockfish should not be disposed yet
      if (currentState == "disposed") {
        AppLogger.error('Stockfish is already disposed - this should not happen', tag: 'AIActionHandler');
        return null;
      }
      
      // Wait for Stockfish to be ready if it's not already
      if (currentState != "ready") {
        AppLogger.info('Waiting for Stockfish to be ready (current state: $currentState)...', tag: 'AIActionHandler');
        try {
          await _stockfishInterpreter.waitForReady();
          AppLogger.info('Stockfish is now ready', tag: 'AIActionHandler');
        } catch (e) {
          AppLogger.error('Failed to wait for Stockfish to be ready: $e', tag: 'AIActionHandler');
          return null;
        }
      }
      
      // Get current FEN position to verify board state is synced
      AppLogger.info('Step 1: Getting current FEN position from Stockfish', tag: 'AIActionHandler');
      final fenPosition = await _stockfishInterpreter.getFenPosition();
      AppLogger.info('Current FEN position: $fenPosition', tag: 'AIActionHandler');
      
      // Visualize board to sync state (optional but helps with debugging)
      AppLogger.info('Step 2: Visualizing board in Stockfish', tag: 'AIActionHandler');
      await _stockfishInterpreter.visualizeBoard();
      AppLogger.info('Board visualization completed', tag: 'AIActionHandler');
      
      // Get the best move from Stockfish
      AppLogger.info('Step 3: Requesting best move from Stockfish (this may take a moment)...', tag: 'AIActionHandler');
      final bestMove = await _stockfishInterpreter.getBestMove();
      AppLogger.info('Stockfish response received: $bestMove', tag: 'AIActionHandler');

      if (bestMove.isNullOrEmpty) {
        AppLogger.warning('Stockfish returned no move (null or empty)', tag: 'AIActionHandler');
        AppLogger.warning('This could mean: 1) No legal moves available, 2) Stockfish engine error, 3) Board state mismatch', tag: 'AIActionHandler');
        return null;
      }

      // Extract move from "bestmove e2e4" format
      AppLogger.info('Step 4: Parsing Stockfish response: $bestMove', tag: 'AIActionHandler');
      final moveParts = bestMove!.split(" ");
      AppLogger.debug('Move parts: $moveParts (length: ${moveParts.length})', tag: 'AIActionHandler');
      
      if (moveParts.length < 2) {
        AppLogger.warning('Invalid move format from Stockfish. Expected format: "bestmove e2e4", Got: $bestMove', tag: 'AIActionHandler');
        return null;
      }

      final move = moveParts[1];
      AppLogger.info('Step 5: AI move extracted successfully: $move', tag: 'AIActionHandler');
      AppLogger.info('=== AIActionHandler.getOpponentsMove() SUCCESS: $move ===', tag: 'AIActionHandler');
      return move;
    } catch (e, stackTrace) {
      AppLogger.error('=== AIActionHandler.getOpponentsMove() ERROR ===', tag: 'AIActionHandler', error: e, stackTrace: stackTrace);
      AppLogger.error('Error details: $e', tag: 'AIActionHandler');
      return null;
    }
  }

  @override
  Future<void> makeMove(String action) async {
    AppLogger.info('=== AIActionHandler.makeMove() START: $action ===', tag: 'AIActionHandler');
    try {
      AppLogger.info('Stockfish state before move: ${_stockfishInterpreter.state}', tag: 'AIActionHandler');
      AppLogger.info('Applying move to Stockfish: $action', tag: 'AIActionHandler');
      
      await _stockfishInterpreter.makeMovesFromCurrentPosition([action]);
      
      AppLogger.info('Move applied successfully in Stockfish', tag: 'AIActionHandler');
      
      // Verify the move was applied by getting FEN
      final fenAfterMove = await _stockfishInterpreter.getFenPosition();
      AppLogger.info('FEN position after move: $fenAfterMove', tag: 'AIActionHandler');
      AppLogger.info('=== AIActionHandler.makeMove() SUCCESS ===', tag: 'AIActionHandler');
    } catch (e, stackTrace) {
      AppLogger.error('=== AIActionHandler.makeMove() ERROR ===', tag: 'AIActionHandler', error: e, stackTrace: stackTrace);
      AppLogger.error('Failed to apply move $action to Stockfish: $e', tag: 'AIActionHandler');
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
