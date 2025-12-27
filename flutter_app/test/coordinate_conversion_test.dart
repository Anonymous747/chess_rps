import 'package:flutter_test/flutter_test.dart';
import 'package:chess_rps/domain/model/position.dart';
import 'package:chess_rps/common/enum.dart';
import 'package:chess_rps/presentation/mediator/player_side_mediator.dart';

void main() {
  group('Coordinate Conversion Tests for AI Games', () {
    test('White player: e2e4 conversion', () {
      // Set player side to white
      PlayerSideMediator.changePlayerSide(Side.light);
      
      // Stockfish returns "e2e4" (white's perspective)
      final fromNotation = "e2";
      final toNotation = "e4";
      
      // Convert to internal coordinates
      final fromPos = fromNotation.convertFromAbsoluteNotationForAI();
      final toPos = toNotation.convertFromAbsoluteNotationForAI();
      
      // e2 should be: col 4 (e), row 1 (2 -> 7-1 = 6, wait no, row 2 -> 7-2+1 = 6)
      // Actually: row 2 -> row.reversed = 7 - 2 + 1 = 6
      expect(fromPos.col, 4); // e is column 4
      expect(fromPos.row, 6); // row 2 -> 7 - 2 + 1 = 6
      
      expect(toPos.col, 4); // e is column 4
      expect(toPos.row, 4); // row 4 -> 7 - 4 + 1 = 4
      
      // Convert back to player perspective
      final fromPlayer = fromPos.algebraicPosition;
      final toPlayer = toPos.algebraicPosition;
      
      expect(fromPlayer, "e2");
      expect(toPlayer, "e4");
    });
    
    test('Black player: e2e4 conversion (AI move)', () {
      // Set player side to black
      PlayerSideMediator.changePlayerSide(Side.dark);
      
      // Stockfish returns "e2e4" (white's perspective, absolute)
      final fromNotation = "e2";
      final toNotation = "e4";
      
      // Convert to internal coordinates
      final fromPos = fromNotation.convertFromAbsoluteNotationForAI();
      final toPos = toNotation.convertFromAbsoluteNotationForAI();
      
      // For black: e2 -> col 4 (e), row 1 (2 - 1 = 1)
      // Actually: row 2 -> row - 1 = 1
      expect(fromPos.col, 4); // e is column 4
      expect(fromPos.row, 1); // row 2 -> 2 - 1 = 1
      
      expect(toPos.col, 4); // e is column 4
      expect(toPos.row, 3); // row 4 -> 4 - 1 = 3
      
      // Convert back to player perspective (black's view)
      final fromPlayer = fromPos.algebraicPosition;
      final toPlayer = toPos.algebraicPosition;
      
      // For black: internal (1, 4) should display as "d2"
      // col 4 -> col.reversed - 1 = (8-4) - 1 = 3 -> "d"
      // row 1 -> row + 1 = 2
      expect(fromPlayer, "d2");
      expect(toPlayer, "d4");
    });
    
    test('Black player: e4d5 conversion (capture move)', () {
      // Set player side to black
      PlayerSideMediator.changePlayerSide(Side.dark);
      
      // Stockfish returns "e4d5" (white pawn on e4 captures black pawn on d5)
      final fromNotation = "e4";
      final toNotation = "d5";
      
      // Convert to internal coordinates
      final fromPos = fromNotation.convertFromAbsoluteNotationForAI();
      final toPos = toNotation.convertFromAbsoluteNotationForAI();
      
      // e4 -> col 4 (e), row 3 (4 - 1 = 3)
      expect(fromPos.col, 4);
      expect(fromPos.row, 3);
      
      // d5 -> col 3 (d), row 4 (5 - 1 = 4)
      expect(toPos.col, 3);
      expect(toPos.row, 4);
      
      // Convert back to player perspective (black's view)
      final fromPlayer = fromPos.algebraicPosition;
      final toPlayer = toPos.algebraicPosition;
      
      // Internal (3, 4) -> col 4 -> col.reversed - 1 = (8-4) - 1 = 3 -> "d"
      // row 3 -> row + 1 = 4 -> "d4"
      // Internal (4, 3) -> col 3 -> col.reversed - 1 = (8-3) - 1 = 4 -> "e"
      // row 4 -> row + 1 = 5 -> "e5"
      expect(fromPlayer, "d4");
      expect(toPlayer, "e5");
    });
    
    test('White player: e4d5 conversion (capture move)', () {
      // Set player side to white
      PlayerSideMediator.changePlayerSide(Side.light);
      
      // Stockfish returns "e4d5" (white pawn on e4 captures black pawn on d5)
      final fromNotation = "e4";
      final toNotation = "d5";
      
      // Convert to internal coordinates
      final fromPos = fromNotation.convertFromAbsoluteNotationForAI();
      final toPos = toNotation.convertFromAbsoluteNotationForAI();
      
      // e4 -> col 4 (e), row 4 (4 -> 7-4+1 = 4)
      expect(fromPos.col, 4);
      expect(fromPos.row, 4);
      
      // d5 -> col 3 (d), row 3 (5 -> 7-5+1 = 3)
      expect(toPos.col, 3);
      expect(toPos.row, 3);
      
      // Convert back to player perspective
      final fromPlayer = fromPos.algebraicPosition;
      final toPlayer = toPos.algebraicPosition;
      
      expect(fromPlayer, "e4");
      expect(toPlayer, "d5");
    });
  });
}

