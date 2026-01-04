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
      var currentState = _stockfishInterpreter.state;
      AppLogger.info('Stockfish state before wait: $currentState', tag: 'AIActionHandler');
      
      // If disposed, try to reinitialize Stockfish
      if (currentState == "disposed") {
        AppLogger.warning('Stockfish is disposed - attempting to reinitialize', tag: 'AIActionHandler');
        try {
          _stockfishInterpreter.initEngine();
          AppLogger.info('Stockfish reinitialized, waiting for ready state', tag: 'AIActionHandler');
          await _stockfishInterpreter.waitForReady();
          // Update state after reinitialization
          currentState = _stockfishInterpreter.state;
          AppLogger.info('Stockfish is now ready after reinitialization (state: $currentState)', tag: 'AIActionHandler');
          
          // After reinitialization, we need to sync the board state with Stockfish
          // The board state might have changed, so we need to visualize it again
          AppLogger.info('Syncing board state with Stockfish after reinitialization', tag: 'AIActionHandler');
          await _stockfishInterpreter.visualizeBoard();
          AppLogger.info('Board state synced after reinitialization', tag: 'AIActionHandler');
        } catch (e) {
          AppLogger.error('Failed to reinitialize Stockfish: $e', tag: 'AIActionHandler', error: e);
          return null;
        }
      }
      
      // Wait for Stockfish to be ready if it's not already
      // Use currentState which may have been updated after reinitialization
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
      
      // Get the best move from Stockfish with 5 second maximum time limit (5000 milliseconds)
      AppLogger.info('Step 3: Requesting best move from Stockfish (max 5 seconds)...', tag: 'AIActionHandler');
      final bestMove = await _stockfishInterpreter.getBestMoveTime(time: 5000);
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
      
      // Stockfish expects moves in format "e2e4" (without piece prefix)
      // But our action format is "Pe2e4" (with piece prefix)
      // Strip the piece prefix if present
      String stockfishMove = action;
      if (action.length == 5) {
        // Format: "Pe2e4" -> extract "e2e4"
        stockfishMove = action.substring(1);
        AppLogger.info('Stripped piece prefix from move: $action -> $stockfishMove', tag: 'AIActionHandler');
      } else if (action.length != 4) {
        AppLogger.warning('Unexpected move format: $action (length: ${action.length})', tag: 'AIActionHandler');
        AppLogger.warning('Expected format: "e2e4" (4 chars) or "Pe2e4" (5 chars)', tag: 'AIActionHandler');
      }
      
      AppLogger.info('Applying move to Stockfish: $stockfishMove', tag: 'AIActionHandler');
      
      await _stockfishInterpreter.makeMovesFromCurrentPosition([stockfishMove]);
      
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

  /// Get current FEN position from Stockfish
  Future<String> getFenPosition() async {
    return await _stockfishInterpreter.getFenPosition();
  }

  /// Rebuild Stockfish board state from move history
  /// This is used when board state gets out of sync
  /// [turn] is an optional turn indicator ('w' or 'b') to set when at starting position
  /// This is useful for RPS mode where the turn order doesn't follow standard chess rules
  Future<void> rebuildBoardFromMoves(List<String> moveHistory, {String? turn}) async {
    AppLogger.info('Rebuilding Stockfish board from ${moveHistory.length} moves', tag: 'AIActionHandler');
    
    // Extract moves without piece prefixes (Stockfish format: "e2e4")
    final stockfishMoves = <String>[];
    for (final move in moveHistory) {
      // Remove piece prefix if present (e.g., "Pe2e4" -> "e2e4", "Pe2e4q" -> "e2e4q")
      // Moves can be 4 chars (e2e4), 5 chars (Pe2e4), or 6 chars (Pe2e4q for promotion)
      String stockfishMove = move;
      if (move.length >= 5 && move[0].toUpperCase() == move[0] && move[0].contains(RegExp(r'[PNBRQK]'))) {
        // Has piece prefix, remove it (keep the rest including promotion suffix)
        stockfishMove = move.substring(1);
      }
      stockfishMoves.add(stockfishMove);
    }
    
    AppLogger.info('Rebuilding board with moves: $stockfishMoves', tag: 'AIActionHandler');
    
    // Determine the initial turn based on the first move if not explicitly provided
    String? initialTurn = turn;
    if (initialTurn == null && stockfishMoves.isNotEmpty) {
      // Determine which side the first move belongs to based on the starting square
      // In chess notation, rows 1-2 are white's starting rows, rows 7-8 are black's starting rows
      final firstMove = stockfishMoves[0];
      if (firstMove.length >= 2) {
        final fromRow = int.tryParse(firstMove[1]);
        if (fromRow != null) {
          // Row 1-2 = white's starting rows, Row 7-8 = black's starting rows
          if (fromRow >= 1 && fromRow <= 2) {
            initialTurn = 'w'; // White to move first
            AppLogger.info('Detected first move is white\'s (from row $fromRow), setting initial turn to w', tag: 'AIActionHandler');
          } else if (fromRow >= 7 && fromRow <= 8) {
            initialTurn = 'b'; // Black to move first
            AppLogger.info('Detected first move is black\'s (from row $fromRow), setting initial turn to b', tag: 'AIActionHandler');
          }
        }
      }
    }
    
    // If at starting position (no moves) and turn is specified, use setPositionWithTurn
    // If we have moves and detected the initial turn, use setPositionWithTurn
    // Otherwise, use standard setPosition
    if (stockfishMoves.isEmpty && initialTurn != null) {
      AppLogger.info('Setting starting position with turn: $initialTurn', tag: 'AIActionHandler');
      try {
        AppLogger.info('Attempting to set starting position with turn: $initialTurn', tag: 'AIActionHandler');
        await _stockfishInterpreter.setPositionWithTurn(initialTurn, stockfishMoves);
        AppLogger.info('Starting position set with turn: $initialTurn', tag: 'AIActionHandler');
      } catch (e) {
        AppLogger.warning('Failed to set starting position with turn $initialTurn: $e', tag: 'AIActionHandler');
        AppLogger.warning('Falling back to standard starting position (white to move)', tag: 'AIActionHandler');
        // Fall back to standard starting position
        try {
          await _stockfishInterpreter.setPosition(stockfishMoves);
          AppLogger.info('Standard starting position set successfully', tag: 'AIActionHandler');
        } catch (e2) {
          AppLogger.error('Failed to set standard starting position: $e2', tag: 'AIActionHandler');
          // Continue anyway - the move request might still work
        }
      }
    } else if (stockfishMoves.isNotEmpty && initialTurn != null) {
      // We have moves and detected the initial turn - use setPositionWithTurn
      AppLogger.info('Setting starting position with detected turn: $initialTurn, then applying ${stockfishMoves.length} moves', tag: 'AIActionHandler');
      try {
        await _stockfishInterpreter.setPositionWithTurn(initialTurn, stockfishMoves);
        AppLogger.info('Board rebuilt with initial turn $initialTurn and ${stockfishMoves.length} moves', tag: 'AIActionHandler');
      } catch (e) {
        AppLogger.warning('Failed to set position with turn $initialTurn: $e', tag: 'AIActionHandler');
        AppLogger.warning('Falling back to standard starting position (white to move)', tag: 'AIActionHandler');
        // Fall back to standard starting position
        try {
          await _stockfishInterpreter.setPosition(stockfishMoves);
          AppLogger.info('Standard starting position set successfully', tag: 'AIActionHandler');
        } catch (e2) {
          AppLogger.error('Failed to set standard starting position: $e2', tag: 'AIActionHandler');
          // Continue anyway - the move request might still work
        }
      }
    } else {
      // Reset to starting position and apply all moves (standard chess - white to move first)
      AppLogger.info('Using standard starting position (white to move first)', tag: 'AIActionHandler');
      await _stockfishInterpreter.setPosition(stockfishMoves);
    }
    
    AppLogger.info('Board rebuilt successfully', tag: 'AIActionHandler');
  }

  /// Set FEN position with a specific turn indicator
  /// This is useful in RPS mode when we need to set the turn to match the RPS winner
  Future<void> setFenPosition(String fenPosition) async {
    AppLogger.info('Setting FEN position: $fenPosition', tag: 'AIActionHandler');
    await _stockfishInterpreter.setFenPosition(fenPosition: fenPosition, sendUcinewgameToken: false);
    
    // Verify the FEN was set correctly by reading it back
    await Future.delayed(const Duration(milliseconds: 100)); // Small delay to ensure FEN is processed
    final verifyFen = await _stockfishInterpreter.getFenPosition();
    AppLogger.info('FEN position set. Verification: $verifyFen', tag: 'AIActionHandler');
    
    // Check if turn matches
    final fenParts = verifyFen.split(' ');
    final setFenParts = fenPosition.split(' ');
    if (fenParts.length >= 2 && setFenParts.length >= 2) {
      final actualTurn = fenParts[1];
      final expectedTurn = setFenParts[1];
      if (actualTurn != expectedTurn) {
        AppLogger.warning(
          'FEN turn mismatch! Set: $expectedTurn, Actual: $actualTurn',
          tag: 'AIActionHandler'
        );
      } else {
        AppLogger.info('FEN turn verified: $actualTurn', tag: 'AIActionHandler');
      }
    }
  }

  @override
  Future<void> dispose() async {
    AppLogger.info('Disposing AIActionHandler', tag: 'AIActionHandler');
    _stockfishInterpreter.disposeEngine();
    AppLogger.debug('AIActionHandler disposed', tag: 'AIActionHandler');
  }
}
