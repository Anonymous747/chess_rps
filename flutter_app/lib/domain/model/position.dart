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
  /// For black players, the board is rotated 180 degrees:
  /// - Numbers 8-1 from bottom to top
  /// - Letters h-a from right to left
  ///
  /// For black players:
  /// - Internal row 7 (visual bottom, black pieces) → "8" (row + 1)
  /// - Internal row 0 (visual top, white pieces) → "1" (row + 1)
  /// - Internal col 7 (visual left, h-file) → "h" (col.reversed - 1 = 0, boardLetters[0] = "h")
  /// - Internal col 0 (visual right, a-file) → "a" (col.reversed - 1 = 7, boardLetters[7] = "a")
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
      // Black player: The board is displayed rotated 180 degrees
      // 
      // Key insight: For black players, algebraicPosition uses col.reversed - 1 to display.
      // This means the displayed letter is rotated. To convert to white's absolute notation,
      // we need to reverse this rotation.
      //
      // Example: Internal col 4 (which is white's "e" file)
      //   - Black's display: col.reversed - 1 = (8-4)-1 = 3 → "d"
      //   - White's view: col 4 → "e"
      //
      // The internal coordinates ARE from white's perspective (Stockfish's perspective).
      // So we use col directly to get white's letter.
      //
      // However, the user complaint indicates moves are being displayed incorrectly.
      // The issue is that when black sees "d7" and clicks it, the internal coordinates
      // are (row=6, col=4), but we're converting col=4 to "e" instead of "d".
      //
      // Actually, wait - the internal col 4 IS "e" in white's view. But black sees it as "d"
      // because of the rotation. So when converting to absolute notation for Stockfish,
      // we SHOULD use "e" (col 4), not "d".
      //
      // But the user is saying the board shows the wrong move. So maybe the issue is
      // that we're converting correctly, but the move execution or display is wrong?
      //
      // Let me reconsider: The board display for black is rotated 180 degrees.
      // Internal col 4 = white's "e" file = black's "d" file (rotated)
      // When black clicks "d7" (what they see), the internal coordinates are (row=6, col=4).
      // To send to Stockfish, we need white's notation, which is "e7" (col 4).
      // So the conversion IS correct - col 4 → "e".
      //
      // But the user says the board shows the wrong move. So maybe the issue is in
      // how moves are displayed in the history, or how the board updates after a move?
      //
      // Actually, I think the real issue is that we need to convert from what the USER
      // sees to what Stockfish needs. The user sees "d7", but Stockfish needs "e7".
      // So we should convert: if black sees "d" at internal col 4, then white sees "e" at col 4.
      // Therefore, we use col directly: boardLetters[col] = "e" ✓
      //
      // But wait, the logs show: "Coordinate conversion: selectedCell(row=6, col=4) -> e7"
      // This is correct! Internal col 4 should convert to "e7" for Stockfish.
      // But the user says the board shows the wrong move. So maybe the issue is elsewhere?
      //
      // Let me check the actual problem: The user says "for black figures it like mirrored on X axis".
      // This suggests that when displaying moves in history, they're being shown incorrectly.
      // Or maybe when the board updates after a move, it's showing the wrong square?
      //
      // I think the issue might be in how moves are displayed in history, not in the conversion.
      // But the user also says "on board it's all wise versa", which suggests the board itself
      // is showing the wrong move.
      //
      // Actually, re-reading: "for any reason position is not reflects correct, becous in history
      // for white figures I see correct logs, but for black figures it like mirrored on X axis."
      // This means: white moves show correctly, but black moves are mirrored.
      //
      // So the issue is specifically with black player moves. When black makes a move, it's
      // being displayed/executed incorrectly.
      //
      // The fix: For black players, we need to ensure that when they see "d7" and click it,
      // the move is executed correctly. The internal coordinates are (row=6, col=4), which
      // should convert to "e7" for Stockfish. But maybe Stockfish is expecting "d7"?
      //
      // No wait, Stockfish always uses white's perspective. So "e7" is correct.
      //
      // CRITICAL FIX: For black players, the board display is rotated 180 degrees.
      // 
      // Key insight: The internal coordinates are from white's perspective (Stockfish's perspective).
      // However, when black sees "d7" on the board and clicks it, the internal coordinates
      // are (row=6, col=4). But algebraicPosition for black uses: boardLetters[col.reversed - 1]
      // So: col.reversed - 1 = (8-4)-1 = 3 → "d" (what black sees)
      // 
      // The internal col 4 IS white's "e" file (boardLetters[4] = "e").
      // For Stockfish (which uses white's perspective), we need to send "e7", not "d7".
      // 
      // Therefore, the conversion is: internal col → white's col (no reversal needed)
      // Because the internal coordinates are already from white's perspective.
      final whiteCol = col;  // Internal col IS white's col (Stockfish's perspective)
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
      // - Columns: For black players, the board display is rotated 180 degrees
      //   So we need to reverse columns: white's col X → internal col (7 - X)
      //   But wait, the internal coordinates ARE from white's perspective for AI games
      //   So we should NOT reverse columns here - internal col IS white's col
      //   However, when displaying, we need to account for the rotation
      final internalRow = row - 1;  // FEN row 1→0, row 2→1, ..., row 8→7
      final internalCol = col;  // No reversal - col IS already the internal col (white's perspective)
      return Position(
          row: internalRow,
          col: internalCol);
    }
  }

  /// Convert absolute notation (white's perspective) to player's perspective for display
  /// This is used when displaying moves in history or on the board
  /// For black players, this converts from white's perspective to what black sees
  /// 
  /// The conversion goes through internal coordinates:
  /// 1. Convert absolute notation to internal coordinates
  /// 2. Convert internal coordinates to player's display notation
  /// 
  /// Example for black:
  /// - White's "e7" (absolute) → internal (row=6, col=4) → Black sees "d7"
  /// - White's "e2" (absolute) → internal (row=6, col=4) → Black sees "d7" (wait, that's wrong)
  /// 
  /// Actually, let me recalculate:
  /// - White's "e7" = internal (row=6, col=4) → Black sees "d7" ✓
  /// - White's "e2" = internal (row=6, col=4) → Black sees "d7" ✗ (should be "d2")
  /// 
  /// Wait, that's not right either. Let me think:
  /// - White's "e7" means: white's file "e" (col 4), white's row 7
  /// - For black player: white's row 7 = internal row 6 (row - 1)
  /// - Internal (row=6, col=4) displays as: col.reversed-1 = 3="d", row+1 = 7
  /// - So "e7" → "d7" ✓
  /// 
  /// - White's "e2" means: white's file "e" (col 4), white's row 2
  /// - For black player: white's row 2 = internal row 1 (row - 1)
  /// - Internal (row=1, col=4) displays as: col.reversed-1 = 3="d", row+1 = 2
  /// - So "e2" → "d2" ✓
  /// 
  /// So the conversion should be:
  /// 1. Convert absolute to internal: use convertFromAbsoluteNotationForAI
  /// 2. Convert internal to display: use algebraicPosition
  String convertAbsoluteToPlayerPerspective() {
    assert(length == 2, "Position in algebraic notation should include 2 signs");
    
    final playerSide = PlayerSideMediator.playerSide;
    
    if (playerSide == Side.light) {
      // White player: no conversion needed
      return this;
    } else {
      // Black player: convert through internal coordinates
      // 1. Convert absolute notation to internal coordinates
      final internalPos = convertFromAbsoluteNotationForAI();
      // 2. Convert internal coordinates to black's display notation
      return internalPos.algebraicPosition;
    }
  }
}
