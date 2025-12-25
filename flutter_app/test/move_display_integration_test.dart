import 'package:flutter_test/flutter_test.dart';
import 'package:chess_rps/common/piece_notation.dart';
import 'package:chess_rps/common/enum.dart';
import 'package:chess_rps/presentation/mediator/player_side_mediator.dart';
import 'package:chess_rps/presentation/mediator/game_mode_mediator.dart';
import 'package:chess_rps/presentation/state/game_state.dart';
import 'package:chess_rps/domain/model/board.dart';

void main() {
  group('Move Display Integration Tests', () {
    setUp(() {
      PlayerSideMediator.makeByDefault();
      GameModesMediator.changeOpponentMode(OpponentMode.ai);
    });

    test('Black player: AI opponent move e2e4 should be stored and displayed correctly', () {
      // Simulate the scenario from logs: black player, AI game, opponent (white) moves e2e4
      PlayerSideMediator.changePlayerSide(Side.dark);
      
      // Move stored in history (as shown in logs: "Pe2e4")
      final moveHistory = ["Pe2e4"];
      
      // 1. Verify move is stored correctly
      expect(moveHistory.last, "Pe2e4", reason: 'Move should be stored as Pe2e4');
      
      // 2. Parse the move
      final parsed = PieceNotation.parseMoveNotation(moveHistory.last);
      expect(parsed['from'], "e2", reason: 'Parsed from should be e2, not d2');
      expect(parsed['to'], "e4", reason: 'Parsed to should be e4, not d4');
      
      // 3. Create game state and test getLastMovePositions
      final board = Board()..startGame();
      final gameState = GameState(
        board: board,
        playerSide: Side.dark,
        moveHistory: moveHistory,
      );
      
      // 4. Get last move positions for board highlighting
      final lastMovePositions = gameState.getLastMovePositions();
      expect(lastMovePositions, isNotNull);
      
      // For black player, e2 should convert to internal row 1, col 4
      expect(lastMovePositions!['fromRow'], 1, reason: 'e2 should map to internal row 1');
      expect(lastMovePositions['fromCol'], 4, reason: 'e2 should map to internal col 4 (e-file)');
      
      // e4 should convert to internal row 3, col 4
      expect(lastMovePositions['toRow'], 3, reason: 'e4 should map to internal row 3');
      expect(lastMovePositions['toCol'], 4, reason: 'e4 should map to internal col 4 (e-file)');
      
      // 5. Verify move history widget would display correctly
      // Widget displays: "$from → $to" where from and to come from parsed move
      final from = parsed['from'] as String;
      final to = parsed['to'] as String;
      expect(from, "e2", reason: 'Move history should display e2, not d2');
      expect(to, "e4", reason: 'Move history should display e4, not d4');
    });

    test('Round-trip: Store e2e4, parse it, verify it displays as e2e4', () {
      PlayerSideMediator.changePlayerSide(Side.dark);
      
      // Create move notation
      final moveNotation = PieceNotation.createMoveNotation(Role.pawn, "e2", "e4");
      expect(moveNotation, "Pe2e4");
      
      // Store in history
      final moveHistory = [moveNotation];
      
      // Parse back
      final parsed = PieceNotation.parseMoveNotation(moveHistory.last);
      
      // Verify parsing
      expect(parsed['from'], "e2", reason: 'Round-trip: from should be e2');
      expect(parsed['to'], "e4", reason: 'Round-trip: to should be e4');
      
      // This is what move history widget displays
      final displayText = "${parsed['from']} → ${parsed['to']}";
      expect(displayText, "e2 → e4", reason: 'Display should show e2 → e4, not d2 → d4');
    });
  });
}

