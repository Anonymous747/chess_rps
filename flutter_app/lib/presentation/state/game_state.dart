import 'package:chess_rps/common/enum.dart';
import 'package:chess_rps/common/rps_choice.dart';
import 'package:chess_rps/presentation/mediator/game_mode_mediator.dart';
import 'package:chess_rps/domain/model/board.dart';
import 'package:chess_rps/domain/model/position.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'game_state.freezed.dart';

@freezed
class GameState with _$GameState {
  const factory GameState({
    required Board board,
    @Default(Side.light) Side currentOrder,
    @Default(null) String? selectedFigure,
    @Default(Side.light) Side playerSide,
    @Default(false) bool showRpsOverlay,
    @Default(null) RpsChoice? playerRpsChoice,
    @Default(null) RpsChoice? opponentRpsChoice,
    @Default(false) bool waitingForRpsResult,
    @Default(null) bool? playerWonRps,
    @Default(600) int lightPlayerTimeSeconds, // 10 minutes
    @Default(600) int darkPlayerTimeSeconds, // 10 minutes
    @Default(null) DateTime? currentTurnStartedAt,
    @Default(null) Side? kingInCheck, // Which side's king is in check
    @Default([]) List<String> moveHistory, // History of all moves in algebraic notation
    @Default(false) bool gameOver, // Whether the game has ended
    @Default(null) Side? winner, // Which side won (null if draw/stalemate)
    @Default(false) bool isCheckmate, // Whether the game ended in checkmate
    @Default(false) bool isStalemate, // Whether the game ended in stalemate
  }) = _GameState;
}

/// Extension on GameState to get last move positions
extension GameStateExtension on GameState {
  /// Get the last move positions from move history
  /// Returns a map with 'fromRow', 'fromCol', 'toRow', 'toCol' or null if no moves
  /// Note: For AI games, moves are stored in absolute notation (white's perspective)
  ///       For online games, moves are stored from the player's perspective
  Map<String, int>? getLastMovePositions() {
    if (moveHistory.isEmpty) return null;
    
    final lastMove = moveHistory.last;
    if (lastMove.length < 4) return null;
    
    try {
      // Parse algebraic notation - handle both "e2e4" and "Pe2e4" formats
      String fromNotation, toNotation;
      if (lastMove.length == 5) {
        // Format with piece prefix: "Pe2e4"
        fromNotation = lastMove.substring(1, 3);
        toNotation = lastMove.substring(3, 5);
      } else {
        // Format without piece prefix: "e2e4"
        fromNotation = lastMove.substring(0, 2);
        toNotation = lastMove.substring(2, 4);
      }
      
      // For AI games: all moves are stored in absolute notation (from white's perspective)
      //   - Opponent moves (from Stockfish): 4 characters, absolute notation (e.g., "e2e4")
      //   - Player moves: 5 characters with piece prefix, absolute notation (e.g., "Pd7d5")
      // For online games: all moves are in absolute notation from white's perspective
      final isAIGame = GameModesMediator.opponentMode == OpponentMode.ai;
      
      // In AI games, all moves are in absolute notation, so always use absolute notation conversion
      // For online games, moves are also in absolute notation
      final isAbsoluteNotation = isAIGame;
      
      final fromPos = isAbsoluteNotation
          ? fromNotation.convertFromAbsoluteNotationForAI()
          : fromNotation.convertToPosition();
      final toPos = isAbsoluteNotation
          ? toNotation.convertFromAbsoluteNotationForAI()
          : toNotation.convertToPosition();
      
      return {
        'fromRow': fromPos.row,
        'fromCol': fromPos.col,
        'toRow': toPos.row,
        'toCol': toPos.col,
      };
    } catch (e) {
      return null;
    }
  }
}
