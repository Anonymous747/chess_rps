import 'package:flutter_test/flutter_test.dart';
import 'package:chess_rps/domain/model/position.dart';
import 'package:chess_rps/common/enum.dart';
import 'package:chess_rps/presentation/mediator/player_side_mediator.dart';

void main() {
  group('Black Player Coordinate Conversion Tests for AI Games', () {
    test('Black player: c8 to f5 move conversion', () {
      // Set player side to black
      PlayerSideMediator.changePlayerSide(Side.dark);
      
      // User sees c8 at internal position (7, 5)
      // User sees f5 at internal position (4, 2)
      final fromPos = Position(row: 7, col: 5); // c8 from black's perspective
      final toPos = Position(row: 4, col: 2);   // f5 from black's perspective
      
      // Check what black sees (algebraicPosition)
      expect(fromPos.algebraicPosition, "c8");
      expect(toPos.algebraicPosition, "f5");
      
      // For AI games, absoluteAlgebraicPositionForAI should convert to white's perspective
      // Internal (7, 5): col.reversed - 1 = (8-5) - 1 = 2 = "c" (what black sees)
      // To get white's view, we reverse: whiteCol = 7 - col = 7 - 5 = 2 = "c"
      // So c8 should convert to c8 in absolute notation
      final fromAbsolute = fromPos.absoluteAlgebraicPositionForAI;
      final toAbsolute = toPos.absoluteAlgebraicPositionForAI;
      
      // User expects: c8f5 (what they see)
      // For Stockfish, we need absolute notation
      // The conversion should preserve the move direction from black's perspective
      expect(fromAbsolute, "c8");
      expect(toAbsolute, "f5");
    });
    
    test('Black player: d7 to d5 move conversion', () {
      PlayerSideMediator.changePlayerSide(Side.dark);
      
      // User sees d7 at internal (6, 4)
      // User sees d5 at internal (4, 4)
      final fromPos = Position(row: 6, col: 4);
      final toPos = Position(row: 4, col: 4);
      
      expect(fromPos.algebraicPosition, "d7");
      expect(toPos.algebraicPosition, "d5");
      
      final fromAbsolute = fromPos.absoluteAlgebraicPositionForAI;
      final toAbsolute = toPos.absoluteAlgebraicPositionForAI;
      
      // d7: col.reversed - 1 = (8-4) - 1 = 3 = "d"
      // whiteCol = 7 - 4 = 3 = "d" → d7
      expect(fromAbsolute, "d7");
      expect(toAbsolute, "d5");
    });
    
    test('Round-trip conversion: absolute → internal → absolute', () {
      PlayerSideMediator.changePlayerSide(Side.dark);
      
      // Test that convertFromAbsoluteNotationForAI and absoluteAlgebraicPositionForAI are inverses
      final testCases = ["c8", "f5", "d7", "d5", "e2", "e4"];
      
      for (final notation in testCases) {
        final pos = notation.convertFromAbsoluteNotationForAI();
        final backToNotation = pos.absoluteAlgebraicPositionForAI;
        expect(backToNotation, notation, reason: 'Round-trip failed for $notation');
      }
    });
  });
}

