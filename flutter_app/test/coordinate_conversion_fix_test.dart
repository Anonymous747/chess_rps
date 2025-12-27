import 'package:flutter_test/flutter_test.dart';
import 'package:chess_rps/domain/model/position.dart';
import 'package:chess_rps/common/enum.dart';
import 'package:chess_rps/presentation/mediator/player_side_mediator.dart';

void main() {
  group('Coordinate Conversion Fix Tests', () {
    test('Black player: internal row 6, col 4 should convert correctly', () {
      PlayerSideMediator.changePlayerSide(Side.dark);
      
      // Internal coordinates: row 6, col 4
      // This is what black sees as "d7" on the board
      final pos = Position(row: 6, col: 4);
      
      // Convert to absolute notation (white's perspective for Stockfish)
      final absolute = pos.absoluteAlgebraicPositionForAI;
      
      // row.reversed = 8 - 6 = 2
      // col = 4 = "e" (no reversal)
      // So absolute = "e2"
      expect(absolute, "e2");
      
      // Verify the algebraic position (what black sees)
      final algebraic = pos.algebraicPosition;
      expect(algebraic, "d7");  // Black sees "d7"
    });
    
    test('Black player: internal row 4, col 4 should convert correctly', () {
      PlayerSideMediator.changePlayerSide(Side.dark);
      
      final pos = Position(row: 4, col: 4);
      final absolute = pos.absoluteAlgebraicPositionForAI;
      
      // row.reversed = 8 - 4 = 4
      // col = 4 = "e" (no reversal)
      // So absolute = "e4"
      expect(absolute, "e4");
      
      // Verify the algebraic position (what black sees)
      final algebraic = pos.algebraicPosition;
      expect(algebraic, "d5");  // Black sees "d5"
    });
    
    test('Round-trip conversion: d2 -> internal -> d2 (for black player)', () {
      PlayerSideMediator.changePlayerSide(Side.dark);
      
      // Convert "d2" (white's perspective) to internal coordinates
      final pos = "d2".convertFromAbsoluteNotationForAI();
      
      // Convert back to absolute notation
      final back = pos.absoluteAlgebraicPositionForAI;
      
      expect(back, "d2");
    });
    
    test('Round-trip conversion: d4 -> internal -> d4 (for black player)', () {
      PlayerSideMediator.changePlayerSide(Side.dark);
      
      final pos = "d4".convertFromAbsoluteNotationForAI();
      final back = pos.absoluteAlgebraicPositionForAI;
      
      expect(back, "d4");
    });
  });
}

