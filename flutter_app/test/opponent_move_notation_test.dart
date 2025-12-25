import 'package:flutter_test/flutter_test.dart';
import 'package:chess_rps/domain/model/position.dart';
import 'package:chess_rps/common/enum.dart';
import 'package:chess_rps/presentation/mediator/player_side_mediator.dart';
import 'package:chess_rps/common/piece_notation.dart';

void main() {
  group('Opponent Move Notation Tests', () {
    setUp(() {
      // Reset player side before each test
      PlayerSideMediator.makeByDefault();
    });

    test('Black player: Stockfish move e2e4 should show as e2e4 in history (absolute notation)', () {
      // Set player side to black
      PlayerSideMediator.changePlayerSide(Side.dark);
      
      // Stockfish returns "e2e4" (absolute notation, white's perspective)
      final fromNotation = "e2";
      final toNotation = "e4";
      
      // For history, we should use absolute notation (same as Stockfish)
      // NOT player's perspective - this is the bug fix
      final actionForHistory = PieceNotation.createMoveNotation(Role.pawn, fromNotation, toNotation);
      
      // History should show absolute notation: e2e4, not d2d4
      // This is the key fix: we use the original notation from Stockfish directly
      expect(actionForHistory, "Pe2e4", reason: 'History should use absolute notation from Stockfish, not player perspective');
    });
    
    test('White player: Stockfish move e2e4 should show as e2e4 in history (absolute notation)', () {
      // Set player side to white
      PlayerSideMediator.changePlayerSide(Side.light);
      
      // Stockfish returns "e2e4" (absolute notation, white's perspective)
      final fromNotation = "e2";
      final toNotation = "e4";
      
      // For history, we should use absolute notation (same as Stockfish)
      final actionForHistory = PieceNotation.createMoveNotation(Role.pawn, fromNotation, toNotation);
      
      // History should show absolute notation: e2e4
      expect(actionForHistory, "Pe2e4", reason: 'History should use absolute notation from Stockfish');
    });

    test('Black player: Stockfish move e7e5 should show as e7e5 in history (absolute notation)', () {
      // Set player side to black
      PlayerSideMediator.changePlayerSide(Side.dark);
      
      // Stockfish returns "e7e5" (absolute notation, white's perspective)
      final fromNotation = "e7";
      final toNotation = "e5";
      
      // For history, we should use absolute notation (same as Stockfish)
      final actionForHistory = PieceNotation.createMoveNotation(Role.pawn, fromNotation, toNotation);
      
      // History should show absolute notation: e7e5, not d7d5
      // This is the key fix: we use the original notation from Stockfish directly
      expect(actionForHistory, "Pe7e5", reason: 'History should use absolute notation from Stockfish, not player perspective');
    });

    test('White player: Stockfish move e7e5 should show as e7e5 in history (absolute notation)', () {
      // Set player side to white
      PlayerSideMediator.changePlayerSide(Side.light);
      
      // Stockfish returns "e7e5" (absolute notation, white's perspective)
      final fromNotation = "e7";
      final toNotation = "e5";
      
      // For history, we should use absolute notation (same as Stockfish)
      final actionForHistory = PieceNotation.createMoveNotation(Role.pawn, fromNotation, toNotation);
      
      // History should show absolute notation: e7e5
      expect(actionForHistory, "Pe7e5", reason: 'History should use absolute notation from Stockfish');
    });
  });
}
