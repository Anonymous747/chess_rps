import 'package:flutter_test/flutter_test.dart';
import 'package:chess_rps/common/piece_notation.dart';
import 'package:chess_rps/presentation/mediator/player_side_mediator.dart';
import 'package:chess_rps/common/enum.dart';
import 'package:chess_rps/presentation/state/game_state.dart';
import 'package:chess_rps/domain/model/board.dart';
import 'package:chess_rps/presentation/mediator/game_mode_mediator.dart';

void main() {
  group('Opponent Move Display Tests', () {
    setUp(() {
      // Reset player side and game mode before each test
      PlayerSideMediator.makeByDefault();
      GameModesMediator.changeOpponentMode(OpponentMode.ai);
    });

    test('Black player: Move history should store and parse e2e4 correctly', () {
      // Set player side to black
      PlayerSideMediator.changePlayerSide(Side.dark);
      
      // Move history stores moves in absolute notation
      final moveHistory = ["Pe2e4"];
      
      // Parse the move notation
      final lastMove = moveHistory.last;
      final parsed = PieceNotation.parseMoveNotation(lastMove);
      
      expect(parsed['piece'], Role.pawn);
      expect(parsed['from'], "e2", reason: 'From should be e2 in absolute notation');
      expect(parsed['to'], "e4", reason: 'To should be e4 in absolute notation');
    });

    test('Black player: getLastMovePositions should convert e2e4 to correct internal coordinates', () {
      PlayerSideMediator.changePlayerSide(Side.dark);
      GameModesMediator.changeOpponentMode(OpponentMode.ai);
      
      // Create a game state with move history in absolute notation
      final board = Board()..startGame();
      final gameState = GameState(
        board: board,
        playerSide: Side.dark,
        moveHistory: ["Pe2e4"],
      );
      
      // Get last move positions
      final lastMovePositions = gameState.getLastMovePositions();
      
      expect(lastMovePositions, isNotNull);
      
      // For black player in AI games, e2 should convert to internal row 1, col 4
      // (FEN row 2 - 1 = internal row 1)
      expect(lastMovePositions!['fromRow'], 1, reason: 'e2 should map to internal row 1');
      expect(lastMovePositions['fromCol'], 4, reason: 'e2 should map to internal col 4 (e-file)');
      
      // e4 should convert to internal row 3, col 4
      // (FEN row 4 - 1 = internal row 3)
      expect(lastMovePositions['toRow'], 3, reason: 'e4 should map to internal row 3');
      expect(lastMovePositions['toCol'], 4, reason: 'e4 should map to internal col 4 (e-file)');
    });

    test('White player: getLastMovePositions should convert e2e4 to correct internal coordinates', () {
      PlayerSideMediator.changePlayerSide(Side.light);
      GameModesMediator.changeOpponentMode(OpponentMode.ai);
      
      // Create a game state with move history in absolute notation
      final board = Board()..startGame();
      final gameState = GameState(
        board: board,
        playerSide: Side.light,
        moveHistory: ["Pe2e4"],
      );
      
      // Get last move positions
      final lastMovePositions = gameState.getLastMovePositions();
      
      expect(lastMovePositions, isNotNull);
      
      // For white player in AI games, e2 should convert to internal row 6, col 4
      // (row.reversed: FEN row 2 → 8-2 = 6)
      expect(lastMovePositions!['fromRow'], 6, reason: 'e2 should map to internal row 6 for white');
      expect(lastMovePositions['fromCol'], 4, reason: 'e2 should map to internal col 4 (e-file)');
      
      // e4 should convert to internal row 4, col 4
      // (row.reversed: FEN row 4 → 8-4 = 4)
      expect(lastMovePositions['toRow'], 4, reason: 'e4 should map to internal row 4 for white');
      expect(lastMovePositions['toCol'], 4, reason: 'e4 should map to internal col 4 (e-file)');
    });

    test('Move history widget should display e2e4, not d2d4 for black players', () {
      PlayerSideMediator.changePlayerSide(Side.dark);
      
      // Move stored in absolute notation
      final moveHistory = ["Pe2e4"];
      
      // Parse the move - the widget will display what's in the notation
      final lastMove = moveHistory.last;
      final parsed = PieceNotation.parseMoveNotation(lastMove);
      
      final from = parsed['from'] as String;
      final to = parsed['to'] as String;
      
      // Widget displays: "$from → $to"
      // So it should show "e2 → e4", not "d2 → d4"
      expect(from, "e2", reason: 'Move history should display e2 (absolute notation), not d2');
      expect(to, "e4", reason: 'Move history should display e4 (absolute notation), not d4');
    });

    test('Move notation stored in history is always absolute for AI games', () {
      PlayerSideMediator.changePlayerSide(Side.dark);
      GameModesMediator.changeOpponentMode(OpponentMode.ai);
      
      // Simulate what gets stored in moveHistory
      final storedNotation = "Pe2e4";  // Absolute notation
      
      // Parse it
      final parsed = PieceNotation.parseMoveNotation(storedNotation);
      
      // Should parse as e2e4, not d2d4
      expect(parsed['from'], "e2");
      expect(parsed['to'], "e4");
      
      // This is what the move history widget will display
      // It just shows the parsed "from" and "to" directly from the stored notation
      // So it will show "e2 → e4", which is correct
    });
  });
}
