import 'package:chess_rps/common/enum.dart';
import 'package:chess_rps/common/piece_notation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Move Notation Parsing Tests', () {
    test('parseMoveNotation should handle 4-character format (e2e4)', () {
      final result = PieceNotation.parseMoveNotation('e2e4');
      
      expect(result['from'], equals('e2'));
      expect(result['to'], equals('e4'));
      expect(result['piece'], isNull);
    });

    test('parseMoveNotation should handle 5-character format (Pe2e4)', () {
      final result = PieceNotation.parseMoveNotation('Pe2e4');
      
      expect(result['from'], equals('e2'));
      expect(result['to'], equals('e4'));
      expect(result['piece'], isNotNull);
    });

    test('parseMoveNotation should handle other piece types', () {
      final knightMove = PieceNotation.parseMoveNotation('Ng1f3');
      expect(knightMove['from'], equals('g1'));
      expect(knightMove['to'], equals('f3'));
      expect(knightMove['piece'], isNotNull);
      
      final rookMove = PieceNotation.parseMoveNotation('Ra1a3');
      expect(rookMove['from'], equals('a1'));
      expect(rookMove['to'], equals('a3'));
      expect(rookMove['piece'], isNotNull);
    });

    test('parseMoveNotation should return empty for invalid formats', () {
      final invalid1 = PieceNotation.parseMoveNotation('e2');
      expect(invalid1['from'], equals(''));
      expect(invalid1['to'], equals(''));
      
      final invalid2 = PieceNotation.parseMoveNotation('e2e4e6');
      expect(invalid2['from'], equals(''));
      expect(invalid2['to'], equals(''));
    });

    test('createMoveNotation should create correct format', () {
      final pawnMove = PieceNotation.createMoveNotation(
        Role.pawn,
        'e2',
        'e4',
      );
      expect(pawnMove, equals('Pe2e4'));
      
      final knightMove = PieceNotation.createMoveNotation(
        Role.knight,
        'g1',
        'f3',
      );
      expect(knightMove, equals('Ng1f3'));
    });
  });

  group('Move Execution Coordinate Tests', () {
    test('e2e4 should parse to correct column (col 4 for e)', () {
      final result = PieceNotation.parseMoveNotation('e2e4');
      final fromNotation = result['from'] as String;
      final toNotation = result['to'] as String;
      
      // e is the 5th letter (0-indexed = 4)
      expect(fromNotation[0], equals('e'));
      expect(toNotation[0], equals('e'));
      
      // Verify column parsing
      final boardLetters = ['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h'];
      final fromCol = boardLetters.indexOf(fromNotation[0]);
      final toCol = boardLetters.indexOf(toNotation[0]);
      
      expect(fromCol, equals(4), reason: 'e should be at index 4');
      expect(toCol, equals(4), reason: 'e should be at index 4');
    });

    test('d2d4 should parse to correct column (col 3 for d)', () {
      final result = PieceNotation.parseMoveNotation('d2d4');
      final fromNotation = result['from'] as String;
      final toNotation = result['to'] as String;
      
      // d is the 4th letter (0-indexed = 3)
      expect(fromNotation[0], equals('d'));
      expect(toNotation[0], equals('d'));
      
      // Verify column parsing
      final boardLetters = ['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h'];
      final fromCol = boardLetters.indexOf(fromNotation[0]);
      final toCol = boardLetters.indexOf(toNotation[0]);
      
      expect(fromCol, equals(3), reason: 'd should be at index 3');
      expect(toCol, equals(3), reason: 'd should be at index 3');
    });
  });
}

