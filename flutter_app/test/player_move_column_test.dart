import 'package:flutter_test/flutter_test.dart';
import 'package:chess_rps/domain/model/position.dart';
import 'package:chess_rps/common/enum.dart';
import 'package:chess_rps/presentation/mediator/player_side_mediator.dart';
import 'package:chess_rps/presentation/mediator/game_mode_mediator.dart';
import 'package:chess_rps/common/piece_notation.dart';

void main() {
  group('Player Move Column Conversion Tests', () {
    setUp(() {
      PlayerSideMediator.makeByDefault();
      GameModesMediator.changeOpponentMode(OpponentMode.ai);
    });

    test('Black player: Internal col 4 should convert to e-file (not d-file)', () {
      // Set player side to black
      PlayerSideMediator.changePlayerSide(Side.dark);
      
      // Internal col 4 should be e-file in absolute notation
      // (For black, col 4 displays as "d" in player perspective, but should be "e" in absolute)
      final pos = Position(row: 1, col: 4); // Internal position
      final absoluteNotation = pos.absoluteAlgebraicPositionForAI;
      
      expect(absoluteNotation.startsWith('e'), isTrue, 
        reason: 'Internal col 4 should be e-file in absolute notation, got: $absoluteNotation');
      expect(absoluteNotation, 'e2', reason: 'Internal row 1, col 4 should be e2 in absolute notation');
    });

    test('Black player: Move from col 4 to col 4 should show as e-file moves', () {
      PlayerSideMediator.changePlayerSide(Side.dark);
      
      // Black player moves a piece from internal row 1, col 4 to row 3, col 4
      // In player perspective: this appears as d2 to d4
      // In absolute notation: this should be e2 to e4
      final fromPos = Position(row: 1, col: 4);
      final toPos = Position(row: 3, col: 4);
      
      final fromNotation = fromPos.absoluteAlgebraicPositionForAI;
      final toNotation = toPos.absoluteAlgebraicPositionForAI;
      
      expect(fromNotation, 'e2', reason: 'From position should be e2, got: $fromNotation');
      expect(toNotation, 'e4', reason: 'To position should be e4, got: $toNotation');
      
      // Create move notation
      final moveNotation = PieceNotation.createMoveNotation(Role.pawn, fromNotation, toNotation);
      expect(moveNotation, 'Pe2e4', reason: 'Move should be Pe2e4, got: $moveNotation');
    });

    test('Black player: Verify column mapping for all files', () {
      PlayerSideMediator.changePlayerSide(Side.dark);
      
      // Test that internal col 0-7 map correctly to a-h in absolute notation
      final expectedFiles = ['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h'];
      
      for (int col = 0; col < 8; col++) {
        final pos = Position(row: 1, col: col);
        final absoluteNotation = pos.absoluteAlgebraicPositionForAI;
        final expectedFile = expectedFiles[col];
        
        expect(absoluteNotation.startsWith(expectedFile), isTrue,
          reason: 'Internal col $col should map to $expectedFile-file in absolute notation, got: $absoluteNotation');
      }
    });
  });
}


