import 'package:chess_rps/common/enum.dart';
import 'package:chess_rps/domain/model/position.dart';
import 'package:chess_rps/presentation/mediator/player_side_mediator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Black Player Display Conversion Tests', () {
    test('convertAbsoluteToPlayerPerspective: e2 should convert to d2 for black', () {
      PlayerSideMediator.changePlayerSide(Side.dark);
      
      // White's "e2" (absolute) → internal (row=6, col=4) → Black sees "d2"
      // e2: white's row 2 = internal row 6 (8-2=6), col 4 = "e"
      // Internal (row=6, col=4) → black display: col.reversed-1=3="d", row+1=7
      // Wait, that gives "d7", not "d2"
      // Let me recalculate: white's row 2 → internal row? 
      // For black: white's row 2 = internal row 1 (row - 1)
      // Internal (row=1, col=4) → black: col.reversed-1=3="d", row+1=2
      // So "e2" → "d2" ✓
      final result = 'e2'.convertAbsoluteToPlayerPerspective();
      expect(result, equals('d2'));
    });

    test('convertAbsoluteToPlayerPerspective: e7 should convert to d7 for black', () {
      PlayerSideMediator.changePlayerSide(Side.dark);
      
      // White's "e7" (absolute) → internal (row=6, col=4) → Black sees "d7"
      final result = 'e7'.convertAbsoluteToPlayerPerspective();
      expect(result, equals('d7'));
    });

    test('convertAbsoluteToPlayerPerspective: d7 should convert to e7 for black', () {
      PlayerSideMediator.changePlayerSide(Side.dark);
      
      // White's "d7" (absolute) → internal (row=6, col=3) → Black sees "e7"
      final result = 'd7'.convertAbsoluteToPlayerPerspective();
      expect(result, equals('e7'));
    });

    test('convertAbsoluteToPlayerPerspective: d5 should convert to e5 for black', () {
      PlayerSideMediator.changePlayerSide(Side.dark);
      
      // White's "d5" (absolute) → internal (row=4, col=3) → Black sees "e5"
      final result = 'd5'.convertAbsoluteToPlayerPerspective();
      expect(result, equals('e5'));
    });

    test('convertAbsoluteToPlayerPerspective: a1 should convert to h1 for black', () {
      PlayerSideMediator.changePlayerSide(Side.dark);
      
      // White's "a1" (absolute) → internal (row=7, col=0) → Black sees "h1"
      final result = 'a1'.convertAbsoluteToPlayerPerspective();
      expect(result, equals('h1'));
    });

    test('convertAbsoluteToPlayerPerspective: h8 should convert to a8 for black', () {
      PlayerSideMediator.changePlayerSide(Side.dark);
      
      // White's "h8" (absolute) → internal (row=0, col=7) → Black sees "a8"
      final result = 'h8'.convertAbsoluteToPlayerPerspective();
      expect(result, equals('a8'));
    });

    test('convertAbsoluteToPlayerPerspective: e2e4 should convert correctly for black', () {
      PlayerSideMediator.changePlayerSide(Side.dark);
      
      // White moves e2e4 (absolute)
      // e2 → internal (row=1, col=4) → Black sees "d2"
      // e4 → internal (row=3, col=4) → Black sees "d4"
      final from = 'e2'.convertAbsoluteToPlayerPerspective();
      final to = 'e4'.convertAbsoluteToPlayerPerspective();
      
      expect(from, equals('d2'));  // e2 → d2
      expect(to, equals('d4'));    // e4 → d4
    });

    test('convertAbsoluteToPlayerPerspective: e7e5 should convert to d7d5 for black', () {
      PlayerSideMediator.changePlayerSide(Side.dark);
      
      // Black moves d7d5 (what they see) → stored as e7e5 (absolute)
      // When displaying, convert back: e7e5 → d7d5
      // e7 → internal (row=6, col=4) → Black sees "d7"
      // e5 → internal (row=4, col=4) → Black sees "d5"
      final from = 'e7'.convertAbsoluteToPlayerPerspective();
      final to = 'e5'.convertAbsoluteToPlayerPerspective();
      
      expect(from, equals('d7'));  // e7 → d7
      expect(to, equals('d5'));    // e5 → d5
    });

    test('convertAbsoluteToPlayerPerspective: white player should see no change', () {
      PlayerSideMediator.changePlayerSide(Side.light);
      
      final result = 'e2'.convertAbsoluteToPlayerPerspective();
      expect(result, equals('e2'));
    });
  });
}

