import 'package:chess_rps/common/enum.dart';
import 'package:chess_rps/domain/model/position.dart';
import 'package:chess_rps/presentation/mediator/player_side_mediator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Position Coordinate Conversion Tests', () {
    test('White player: e2 should convert correctly', () {
      PlayerSideMediator.changePlayerSide(Side.light);
      
      // Internal coordinates: row=6, col=4 (e2 for white)
      final position = Position(row: 6, col: 4);
      
      // Algebraic position (what white sees)
      expect(position.algebraicPosition, equals('e2'));
      
      // Absolute position for AI (Stockfish perspective)
      expect(position.absoluteAlgebraicPositionForAI, equals('e2'));
    });

    test('Black player: d7 should convert correctly to e7 for Stockfish', () {
      PlayerSideMediator.changePlayerSide(Side.dark);
      
      // Internal coordinates: row=6, col=4
      // For black, this displays as "d7" (because col.reversed - 1 = 3 = "d")
      final position = Position(row: 6, col: 4);
      
      // Algebraic position (what black sees)
      expect(position.algebraicPosition, equals('d7'));
      
      // Absolute position for AI (Stockfish perspective - should be "e7")
      // Internal col 4 = white's "e" file
      expect(position.absoluteAlgebraicPositionForAI, equals('e7'));
    });

    test('Black player: e7 should convert correctly to e7 for Stockfish', () {
      PlayerSideMediator.changePlayerSide(Side.dark);
      
      // Internal coordinates: row=6, col=4
      // This is white's "e7" file
      final position = Position(row: 6, col: 4);
      
      // What black sees (rotated)
      expect(position.algebraicPosition, equals('d7'));
      
      // What Stockfish needs (white's perspective)
      expect(position.absoluteAlgebraicPositionForAI, equals('e7'));
    });

    test('convertFromAbsoluteNotationForAI: e2 for black player', () {
      PlayerSideMediator.changePlayerSide(Side.dark);
      
      // Stockfish sends "e2" (white's perspective)
      final position = 'e2'.convertFromAbsoluteNotationForAI();
      
      // Should convert to internal coordinates
      // FEN row 2 → internal row 1
      // Col "e" (index 4) → internal col 4
      expect(position.row, equals(1));
      expect(position.col, equals(4));
      
      // Verify it displays correctly for black
      expect(position.algebraicPosition, equals('d2'));
    });

    test('convertFromAbsoluteNotationForAI: e4 for black player', () {
      PlayerSideMediator.changePlayerSide(Side.dark);
      
      // Stockfish sends "e4" (white's perspective)
      final position = 'e4'.convertFromAbsoluteNotationForAI();
      
      // Should convert to internal coordinates
      // FEN row 4 → internal row 3
      // Col "e" (index 4) → internal col 4
      expect(position.row, equals(3));
      expect(position.col, equals(4));
      
      // Verify it displays correctly for black
      expect(position.algebraicPosition, equals('d4'));
    });

    test('Round-trip conversion for black player: d7 → e7 → d7', () {
      PlayerSideMediator.changePlayerSide(Side.dark);
      
      // Black sees "d7" and clicks it
      // Internal coordinates: row=6, col=4 (because col.reversed - 1 = 3 = "d")
      // Wait, that's not right. Let me recalculate:
      // If black sees "d" at internal col X: col.reversed - 1 = 3
      // col.reversed = 4
      // col = 4 (since 4.reversed = 4)
      // So internal col 4 displays as "d" for black
      
      // But internal col 4 IS white's "e" file
      // So when black clicks "d7", the internal coordinates are (row=6, col=4)
      final position = Position(row: 6, col: 4);
      
      // What black sees
      expect(position.algebraicPosition, equals('d7'));
      
      // Convert to absolute for Stockfish
      final absolute = position.absoluteAlgebraicPositionForAI;
      expect(absolute, equals('e7'));
      
      // Convert back from absolute
      final convertedBack = absolute.convertFromAbsoluteNotationForAI();
      expect(convertedBack.row, equals(6));
      expect(convertedBack.col, equals(4));
      expect(convertedBack.algebraicPosition, equals('d7'));
    });
  });
}

