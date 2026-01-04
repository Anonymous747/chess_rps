import 'package:flutter_test/flutter_test.dart';
import 'package:chess_rps/domain/model/position.dart';
import 'package:chess_rps/common/enum.dart';
import 'package:chess_rps/presentation/mediator/player_side_mediator.dart';
import 'package:chess_rps/common/piece_notation.dart';

void main() {
  group('AI Move History Display Tests', () {
    test('Black player: AI move e2e4 should convert to d2d4 for history', () {
      PlayerSideMediator.changePlayerSide(Side.dark);
      
      // Stockfish returns "e2e4" (absolute notation, white's perspective)
      final fromNotation = "e2";
      final toNotation = "e4";
      
      // Convert to internal coordinates
      final fromPos = fromNotation.convertFromAbsoluteNotationForAI();
      final toPos = toNotation.convertFromAbsoluteNotationForAI();
      
      // Verify internal coordinates
      expect(fromPos.row, 1);  // e2 -> row 1 (white's row 2)
      expect(fromPos.col, 4);  // e2 -> col 4 (e-file)
      expect(toPos.row, 3);    // e4 -> row 3 (white's row 4)
      expect(toPos.col, 4);    // e4 -> col 4 (e-file)
      
      // Convert to player's perspective for history
      final fromPosPlayer = fromPos.algebraicPosition;
      final toPosPlayer = toPos.algebraicPosition;
      
      // For black: row 1, col 4
      //   col.reversed - 1 = (8 - 4) - 1 = 3 = "d"
      //   row + 1 = 1 + 1 = 2
      //   So displays as "d2"
      expect(fromPosPlayer, "d2");
      
      // For black: row 3, col 4
      //   col.reversed - 1 = (8 - 4) - 1 = 3 = "d"
      //   row + 1 = 3 + 1 = 4
      //   So displays as "d4"
      expect(toPosPlayer, "d4");
      
      // Create move notation for history
      final historyNotation = PieceNotation.createMoveNotation(Role.pawn, fromPosPlayer, toPosPlayer);
      expect(historyNotation, "Pd2d4");
    });
    
    test('Verify internal coordinates for e2 and e4', () {
      PlayerSideMediator.changePlayerSide(Side.dark);
      
      // e2: FEN row 2 -> internal row 1
      final e2 = "e2".convertFromAbsoluteNotationForAI();
      expect(e2.row, 1);
      expect(e2.col, 4);  // e-file = col 4
      
      // e4: FEN row 4 -> internal row 3
      final e4 = "e4".convertFromAbsoluteNotationForAI();
      expect(e4.row, 3);
      expect(e4.col, 4);  // e-file = col 4
      
      // Verify algebraic position for black
      expect(e2.algebraicPosition, "d2");
      expect(e4.algebraicPosition, "d4");
    });
    
    test('Verify e7e5 conversion (should NOT happen for initial move)', () {
      PlayerSideMediator.changePlayerSide(Side.dark);
      
      // e7: FEN row 7 -> internal row 6
      final e7 = "e7".convertFromAbsoluteNotationForAI();
      expect(e7.row, 6);
      expect(e7.col, 4);
      
      // e5: FEN row 5 -> internal row 4
      final e5 = "e5".convertFromAbsoluteNotationForAI();
      expect(e5.row, 4);
      expect(e5.col, 4);
      
      // Verify algebraic position for black
      expect(e7.algebraicPosition, "d7");
      expect(e5.algebraicPosition, "d5");
      
      // This should NOT be the result for e2e4
      final e2 = "e2".convertFromAbsoluteNotationForAI();
      final e4 = "e4".convertFromAbsoluteNotationForAI();
      expect(e2.algebraicPosition, isNot("e7"));
      expect(e4.algebraicPosition, isNot("e5"));
    });
  });
}












