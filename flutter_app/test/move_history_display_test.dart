import 'package:flutter_test/flutter_test.dart';
import 'package:chess_rps/common/piece_notation.dart';
import 'package:chess_rps/common/enum.dart';

void main() {
  group('Move History Display Tests', () {
    test('Parse move notation Pe2e4 should extract e2 and e4 correctly', () {
      // Move stored in history as "Pe2e4" (absolute notation)
      final moveNotation = "Pe2e4";
      
      // Parse it
      final parsed = PieceNotation.parseMoveNotation(moveNotation);
      
      expect(parsed['piece'], Role.pawn, reason: 'Piece should be pawn');
      expect(parsed['from'], "e2", reason: 'From should be e2, not d2');
      expect(parsed['to'], "e4", reason: 'To should be e4, not d4');
      
      // These are what the move history widget will display
      final from = parsed['from'] as String;
      final to = parsed['to'] as String;
      
      // Widget displays: "$from → $to"
      // So it should show "e2 → e4", not "d2 → d4"
      expect(from, "e2", reason: 'Displayed from should be e2');
      expect(to, "e4", reason: 'Displayed to should be e4');
    });

    test('Parse move notation without piece prefix e2e4 should extract e2 and e4 correctly', () {
      // Move stored in history as "e2e4" (absolute notation, without piece prefix)
      final moveNotation = "e2e4";
      
      // Parse it
      final parsed = PieceNotation.parseMoveNotation(moveNotation);
      
      expect(parsed['from'], "e2", reason: 'From should be e2');
      expect(parsed['to'], "e4", reason: 'To should be e4');
    });

    test('Create and parse move notation should preserve absolute notation', () {
      // Create a move in absolute notation
      final moveNotation = PieceNotation.createMoveNotation(Role.pawn, "e2", "e4");
      
      expect(moveNotation, "Pe2e4", reason: 'Created notation should be Pe2e4');
      
      // Parse it back
      final parsed = PieceNotation.parseMoveNotation(moveNotation);
      
      expect(parsed['from'], "e2", reason: 'Parsed from should be e2');
      expect(parsed['to'], "e4", reason: 'Parsed to should be e4');
    });
  });
}


