import 'dart:math';

import 'package:chess_rps/common/enum.dart';
import 'package:chess_rps/common/extension.dart';
import 'package:chess_rps/domain/model/board.dart';
import 'package:chess_rps/presentation/mediator/player_side_mediator.dart';

class Position {
  final int row;
  final int col;

  const Position({required this.row, required this.col});

  int get magnitude => sqrt(col * col + row * row).toInt();
}

extension PositionExtension on Position {
  /// Position represented in algebraic notation
  ///
  String get algebraicPosition {
    return PlayerSideMediator.playerSide == Side.light
        ? "${boardLetters[col]}${row.reversed}"
        : "${boardLetters[col.reversed - 1]}${row + 1}";
  }

  /// Convert to absolute algebraic notation (always from white's perspective)
  /// This is used for online moves to ensure consistent interpretation
  /// The board is always initialized with:
  /// - Row 0-1: Opponent pieces (white if player is black, black if player is white)
  /// - Row 6-7: Player pieces (black if player is black, white if player is white)
  ///
  /// The key insight: The board's internal representation doesn't rotate - only the labels do.
  /// So columns map directly: internal col 0 = white's a, col 7 = white's h (same for both players).
  /// Only rows differ based on player perspective.
  ///
  /// For white player:
  /// - Internal row 7 → white's row 1 (white's back rank)
  /// - Internal row 0 → white's row 8 (black's back rank)
  /// - Formula: white's row = row.reversed
  /// - Columns: internal col = white's col (no change)
  ///
  /// For black player:
  /// - Internal row 0 → white's row 1 (white's back rank)
  /// - Internal row 7 → white's row 8 (black's back rank)
  /// - Formula: white's row = row + 1
  /// - Columns: internal col = white's col (same - board doesn't physically rotate)
  String get absoluteAlgebraicPosition {
    final playerSide = PlayerSideMediator.playerSide;
    
    if (playerSide == Side.light) {
      // White player: row 7 → "1", row 0 → "8", columns stay the same
      return "${boardLetters[col]}${row.reversed}";
    } else {
      // Black player: 
      // The key insight: algebraicPosition for black uses col.reversed - 1 to display
      // So if black sees "d" displayed, that means: boardLetters[col.reversed - 1] = "d"
      // Solving: col.reversed - 1 = 3 (index of "d") → col.reversed = 4 → col = 4
      // 
      // BUT: The same internal col 4, when viewed from white's perspective, shows as "e"
      // (because boardLetters[4] = "e")
      //
      // This means the board squares are the SAME, but the labels differ.
      // So when converting to absolute notation, we need to convert what black sees
      // to what white sees for the same square.
      //
      // If black's algebraicPosition shows "d" for internal col X:
      //   col.reversed - 1 = 3 → col = 4
      // To convert to white's view of the same square:
      //   We need whiteCol such that boardLetters[whiteCol] = the square black sees as "d"
      //   Since both see the same square, we can't just use col directly
      //
      // Actually, I think the solution is: if black sees letter L at internal col X,
      // then white sees letter L at internal col (7 - (X.reversed - 1)) = (7 - (7 - X)) = X
      // Wait, that simplifies to X, so columns map directly?
      //
      // Let me test with actual values:
      // Black sees "d" at internal col 4 → col.reversed - 1 = 3 → col = 4
      // For white: col 4 = boardLetters[4] = "e"
      // So black's "d" (internal col 4) = white's "e" (internal col 4)
      // They're the same square! So we just use col directly.
      
      // Actually wait, I think I misunderstood. Let me check the algebraicPosition calculation again.
      // For black: boardLetters[col.reversed - 1]
      // If col = 4: col.reversed = 4, so col.reversed - 1 = 3 → "d"
      // But boardLetters[4] = "e", so col 4 shows as "e" for white and "d" for black.
      // This means they're seeing DIFFERENT squares, which doesn't make sense.
      //
      // I think the issue is that the board's column coordinate system is different.
      // For black, the leftmost column (internal col 0) is labeled as "h" (reversed),
      // so internal col 0 = black's "h" = white's "a"
      // Therefore: whiteCol = 7 - col (reverse the columns)
      
      final whiteCol = 7 - col;  // Reverse columns: black's left (col 0) = white's right (col 7)
      final whiteRow = row + 1;   // Row 0→1, row 7→8
      return "${boardLetters[whiteCol]}${whiteRow}";
    }
  }
}

extension ToPositionExtension on String {
  Position convertToPosition() {
    assert(
        length == 2, "Position in algebraic notation should include 2 signs");

    final isLightSidePlayer = PlayerSideMediator.playerSide == Side.light;

    int col, row;

    if (isLightSidePlayer) {
      col = boardLetters.indexOf(this[0]);
      row = int.parse(this[1]);
    } else {
      col = boardLetters.reversed.toList().indexOf(this[0]);
      row = int.parse(this[1]);
    }

    return Position(
        row: isLightSidePlayer ? row.reversed : row - 1,
        col: isLightSidePlayer ? col : col);
  }

  /// Convert from absolute algebraic notation (always from white's perspective)
  /// This is used for online moves to ensure consistent interpretation
  /// For black players, the board is initialized from their perspective, so we need
  /// to convert coordinates appropriately
  Position convertFromAbsoluteNotation() {
    assert(
        length == 2, "Position in algebraic notation should include 2 signs");

    final col = boardLetters.indexOf(this[0]);
    final row = int.parse(this[1]);

    // Convert from white's perspective (row 1-8) to internal representation (row 0-7)
    // The board is always initialized with:
    // - Row 0-1: Opponent pieces (white if player is black, black if player is white)
    // - Row 6-7: Player pieces (black if player is black, white if player is white)
    //
    // For white's perspective:
    // - White's row 1 (back rank) = internal row 7
    // - White's row 8 (opponent's back rank) = internal row 0
    //
    // For black player receiving white's move:
    // - White's row 1 should map to internal row 0 (where white pieces are)
    // - White's row 8 should map to internal row 7 (where black pieces are)
    
    final playerSide = PlayerSideMediator.playerSide;
    
    if (playerSide == Side.light) {
      // White player: row 1->7, row 2->6, ..., row 8->0
      return Position(
          row: row.reversed,  // Row 1->7, row 2->6, ..., row 8->0
          col: col);
    } else {
      // Black player: board is initialized with:
      // - Row 0-1: White pieces (opponent, white's row 1-2)
      // - Row 6-7: Black pieces (player, white's row 7-8)
      // So white's row 1 maps to internal row 0, row 2->1, ..., row 8->7
      // Formula: internalRow = row - 1
      //
      // Columns: Since absoluteAlgebraicPosition reverses columns for black (whiteCol = 7 - col),
      // we need to reverse back when receiving: if white sends col X, internal col = 7 - X
      final internalRow = row - 1;  // White's row 1->0, row 2->1, ..., row 8->7
      final internalCol = 7 - col;  // Reverse columns back: white's col X → internal col (7 - X)
      return Position(
          row: internalRow,
          col: internalCol);
    }
  }
}
