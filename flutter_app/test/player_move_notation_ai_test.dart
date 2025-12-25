import 'package:flutter_test/flutter_test.dart';
import 'package:chess_rps/domain/model/position.dart';
import 'package:chess_rps/common/enum.dart';
import 'package:chess_rps/presentation/mediator/player_side_mediator.dart';
import 'package:chess_rps/common/piece_notation.dart';

void main() {
  group('Player Move Notation for AI Games Tests', () {
    setUp(() {
      // Reset player side before each test
      PlayerSideMediator.makeByDefault();
    });

    test('Black player: internal row 1, col 4 should convert to e2 in absolute notation', () {
      // Set player side to black
      PlayerSideMediator.changePlayerSide(Side.dark);
      
      // Internal row 1, col 4 = white's e2 (white's pawn row)
      // This is where white pawn starts from black player's perspective
      final position = Position(row: 1, col: 4);
      final absoluteNotation = position.absoluteAlgebraicPositionForAI;
      
      // Should be e2 (white's perspective)
      expect(absoluteNotation, "e2", reason: 'Internal row 1, col 4 should map to e2 (row 1+1=2, col 4=e)');
    });

    test('Black player: internal row 3, col 4 should convert to e4 in absolute notation', () {
      // Set player side to black
      PlayerSideMediator.changePlayerSide(Side.dark);
      
      // Internal row 3, col 4 = white's e4
      final position = Position(row: 3, col: 4);
      final absoluteNotation = position.absoluteAlgebraicPositionForAI;
      
      // Should be e4 (white's perspective)
      expect(absoluteNotation, "e4", reason: 'Internal row 3, col 4 should map to e4 (row 3+1=4, col 4=e)');
    });

    test('Black player: internal row 6, col 4 should convert to e7 in absolute notation', () {
      // Set player side to black
      PlayerSideMediator.changePlayerSide(Side.dark);
      
      // Internal row 6, col 4 = white's e7 (black's pawn row from white's perspective)
      final position = Position(row: 6, col: 4);
      final absoluteNotation = position.absoluteAlgebraicPositionForAI;
      
      // Should be e7 (white's perspective)
      expect(absoluteNotation, "e7", reason: 'Internal row 6, col 4 should map to e7 (row 6+1=7, col 4=e)');
    });

    test('Black player: internal row 0, col 4 should convert to e1 in absolute notation', () {
      // Set player side to black
      PlayerSideMediator.changePlayerSide(Side.dark);
      
      // Internal row 0, col 4 = white's e1 (white's back rank)
      final position = Position(row: 0, col: 4);
      final absoluteNotation = position.absoluteAlgebraicPositionForAI;
      
      // Should be e1 (white's perspective)
      expect(absoluteNotation, "e1", reason: 'Internal row 0, col 4 should map to e1 (row 0+1=1, col 4=e)');
    });

    test('Black player: round-trip conversion e2 → internal → e2', () {
      PlayerSideMediator.changePlayerSide(Side.dark);
      
      // Convert e2 to internal coordinates
      final internalPos = "e2".convertFromAbsoluteNotationForAI();
      expect(internalPos.row, 1);
      expect(internalPos.col, 4);
      
      // Convert back to absolute notation
      final absoluteNotation = internalPos.absoluteAlgebraicPositionForAI;
      expect(absoluteNotation, "e2", reason: 'Round-trip conversion should preserve notation');
    });

    test('Black player: round-trip conversion e4 → internal → e4', () {
      PlayerSideMediator.changePlayerSide(Side.dark);
      
      // Convert e4 to internal coordinates
      final internalPos = "e4".convertFromAbsoluteNotationForAI();
      expect(internalPos.row, 3);
      expect(internalPos.col, 4);
      
      // Convert back to absolute notation
      final absoluteNotation = internalPos.absoluteAlgebraicPositionForAI;
      expect(absoluteNotation, "e4", reason: 'Round-trip conversion should preserve notation');
    });

    test('Black player: create move notation e2e4 should use absolute notation', () {
      PlayerSideMediator.changePlayerSide(Side.dark);
      
      // Internal positions for e2e4
      final fromPos = "e2".convertFromAbsoluteNotationForAI();  // row 1, col 4
      final toPos = "e4".convertFromAbsoluteNotationForAI();    // row 3, col 4
      
      // Convert to absolute notation for move
      final fromAbs = fromPos.absoluteAlgebraicPositionForAI;
      final toAbs = toPos.absoluteAlgebraicPositionForAI;
      
      // Create move notation
      final moveNotation = PieceNotation.createMoveNotation(Role.pawn, fromAbs, toAbs);
      
      // Should be Pe2e4 (absolute notation)
      expect(moveNotation, "Pe2e4", reason: 'Player move should use absolute notation e2e4, not d2d4');
    });

    test('White player: internal row 6, col 4 should convert to e2 in absolute notation', () {
      // Set player side to white
      PlayerSideMediator.changePlayerSide(Side.light);
      
      // Internal row 6, col 4 = white's e2 (white's pawn row)
      final position = Position(row: 6, col: 4);
      final absoluteNotation = position.absoluteAlgebraicPositionForAI;
      
      // Should be e2 (row.reversed: 6 → 2, col 4 = e)
      expect(absoluteNotation, "e2", reason: 'Internal row 6, col 4 should map to e2 (row.reversed=2, col 4=e)');
    });
  });
}

