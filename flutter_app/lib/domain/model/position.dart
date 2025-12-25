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

  /// Convert to absolute algebraic notation for AI games (Stockfish perspective)
  /// For AI games, columns are NOT reversed - the internal board structure matches Stockfish directly
  /// This is different from online games where columns are reversed for visual display
  /// 
  /// IMPORTANT: The internal board coordinates are always from white's perspective:
  /// - Row 0 = white's row 1 (white's back rank)
  /// - Row 7 = white's row 8 (black's back rank)
  /// - Col 0 = white's a-file
  /// - Col 7 = white's h-file
  /// 
  /// For black players, the display is rotated but internal coordinates stay the same.
  /// However, algebraicPosition for black uses col.reversed - 1 to display, so we need to
  /// reverse that to get the actual internal column, which is already in white's perspective.
  /// 
  /// If black sees letter L displayed at internal col X:
  ///   boardLetters[col.reversed - 1] = L
  ///   Solving: col.reversed - 1 = indexOf(L)
  ///   col.reversed = indexOf(L) + 1
  ///   col = 7 - (indexOf(L) + 1) + 1 = 7 - indexOf(L)
  ///   
  /// Actually, simpler: if black sees "c" (index 2), then:
  ///   col.reversed - 1 = 2
  ///   col.reversed = 3
  ///   col = 4 (since 4.reversed = 4)
  ///   
  /// Wait, let me recalculate: 4.reversed = 8 - 4 = 4, so col.reversed - 1 = 3, not 2.
  /// 
  /// Actually: if col = 5, then col.reversed = 3, so col.reversed - 1 = 2 = index of "c"
  /// So internal col 5 displays as "c" for black.
  /// 
  /// But internal col 5 is white's "f" (boardLetters[5] = "f").
  /// 
  /// So the mapping is: black's display "c" = internal col 5 = white's "f"
  /// To convert: we need to reverse the column display mapping.
  /// 
  /// If black sees letter at position: boardLetters[col.reversed - 1]
  /// Then to get white's letter at the same internal col: boardLetters[col]
  /// 
  /// So we can use col directly! The internal col IS already white's col.
  String get absoluteAlgebraicPositionForAI {
    final playerSide = PlayerSideMediator.playerSide;
    
    if (playerSide == Side.light) {
      // White player: row 7→1, row 0→8, columns stay the same
      return "${boardLetters[col]}${row.reversed}";
    } else {
      // Black player: The internal coordinates are already from white's perspective
      // Row 0 = white's row 1, row 7 = white's row 8
      // Col 0 = white's a, col 7 = white's h
      // 
      // However, algebraicPosition for black uses col.reversed - 1 to display,
      // which means the displayed letter doesn't match the internal col directly.
      // 
      // Example: If black sees "c" displayed at internal col 5:
      //   col.reversed - 1 = 2 (index of "c")
      //   col.reversed = 3
      //   col = 5
      //   But boardLetters[5] = "f"
      //   
      // So internal col 5 displays as "c" for black but is "f" in white's view.
      // 
      // To convert from black's display to white's absolute:
      // If black sees letter L at internal col X, we need to find what white sees at col X.
      // Since the board is NOT physically rotated (only labels are), col X is the same square.
      // So we use col directly: boardLetters[col] gives white's letter.
      // 
      // BUT: The user expects "c8" to convert to "c8", not "f8".
      // This means the board IS physically rotated for display, so we need to reverse columns.
      // 
      // For black players, algebraicPosition uses: boardLetters[col.reversed - 1]
      // This means the display rotates columns 180 degrees.
      // 
      // Example: Internal col 5
      //   - Black sees: col.reversed - 1 = (8-5) - 1 = 2 = "c"
      //   - White sees: col 5 = "f"
      //
      // To convert from internal coordinates to white's absolute notation:
      // We need to reverse the column mapping that's used in algebraicPosition.
      // If black sees letter at index = col.reversed - 1, then:
      //   displayedIndex = col.reversed - 1 = (8 - col) - 1 = 7 - col
      // To get white's column from displayedIndex: whiteCol = 7 - displayedIndex
      //   whiteCol = 7 - (7 - col) = col
      //
      // Wait, that gives us col again! But that's wrong because:
      //   Internal col 5 → black sees "c" (index 2) → white should see "f" (col 5)
      //   So whiteCol = col = 5 = "f" ✓
      //
      // Actually, that's correct! The internal col IS already white's col.
      // The display rotation is just visual - the internal coordinates match Stockfish.
      //
      // But wait, the user complaint says: "I moved c8f5, but displaying like f8c5"
      // This suggests the conversion is swapping the coordinates.
      //
      // Let me check: If user moves from c8 (internal 7,5) to f5 (internal 4,2):
      //   c8: col.reversed - 1 = 2 → col = 5 → whiteCol = 5 = "f" → f8
      //   f5: col.reversed - 1 = 5 → col = 2 → whiteCol = 2 = "c" → c5
      // So we get f8c5, which matches the complaint!
      //
      // The issue is that we're converting from internal coordinates, but we should be
      // converting from what the user sees (algebraicPosition) to absolute.
      // But we don't have that - we only have internal coordinates.
      //
      // Actually, I think the real issue is that convertFromAbsoluteNotationForAI
      // doesn't reverse columns, so internal col IS white's col. But the display DOES
      // reverse columns. So when we convert internal → absolute, we should NOT reverse,
      // but the user sees reversed columns, so there's a mismatch.
      //
      // IMPORTANT: For AI games, the internal coordinates match Stockfish's perspective.
      // The board layout for black players:
      //   - Internal row 0-1: white pieces (opponent) = FEN rows 1-2
      //   - Internal row 6-7: black pieces (player) = FEN rows 7-8
      //   - Internal col 0-7: directly maps to white's a-h (no reversal)
      //
      // Conversion: internalRow → FEN row (white's perspective)
      //   - Internal row 0 → FEN row 1 (white's back rank)
      //   - Internal row 1 → FEN row 2 (white's pawn rank)
      //   - Internal row 6 → FEN row 7 (black's pawn rank)
      //   - Internal row 7 → FEN row 8 (black's back rank)
      //   Formula: FEN row = internalRow + 1
      //
      // This matches _convertFenRowToInternalRow: fenRow - 1 = internalRow
      // So inverse: internalRow + 1 = fenRow
      final whiteCol = col;  // NO reversal - internal col IS white's col
      final whiteRow = row + 1;  // Internal row 0→1, row 1→2, ..., row 7→8
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

  /// Convert from absolute algebraic notation for AI games (Stockfish perspective)
  /// This is used specifically for AI games where Stockfish always uses white's perspective
  /// and columns are NOT reversed (unlike online games)
  /// For AI games, the internal board structure matches Stockfish's perspective directly
  Position convertFromAbsoluteNotationForAI() {
    assert(
        length == 2, "Position in algebraic notation should include 2 signs");

    final col = boardLetters.indexOf(this[0]);
    final row = int.parse(this[1]);

    final playerSide = PlayerSideMediator.playerSide;
    
    if (playerSide == Side.light) {
      // White player: row 1->7, row 2->6, ..., row 8->0 (same as convertFromAbsoluteNotation)
      return Position(
          row: row.reversed,  // Row 1->7, row 2->6, ..., row 8->0
          col: col);
    } else {
      // Black player: For AI games, the board layout matches Stockfish's perspective
      // - Internal row 0-1: white pieces (opponent) = FEN rows 1-2
      // - Internal row 6-7: black pieces (player) = FEN rows 7-8
      // - Formula: internalRow = fenRow - 1 (from _convertFenRowToInternalRow)
      //   So: FEN row 1 → internal row 0, FEN row 2 → internal row 1, ..., FEN row 8 → internal row 7
      // - Columns: No reversal needed - internal col IS white's col
      final internalRow = row - 1;  // FEN row 1→0, row 2→1, ..., row 8→7
      final internalCol = col;  // No reversal - col IS already the internal col
      return Position(
          row: internalRow,
          col: internalCol);
    }
  }
}
