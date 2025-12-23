import 'package:chess_rps/common/enum.dart';

/// Utility class for converting piece roles to chess notation symbols
class PieceNotation {
  /// Get the standard chess notation symbol for a piece role
  /// Returns uppercase letter: P, R, N, B, Q, K
  /// Pawns are represented as 'P' (even though they're often omitted in standard notation)
  static String getPieceSymbol(Role role) {
    switch (role) {
      case Role.pawn:
        return 'P';
      case Role.rook:
        return 'R';
      case Role.knight:
        return 'N';
      case Role.bishop:
        return 'B';
      case Role.queen:
        return 'Q';
      case Role.king:
        return 'K';
    }
  }

  /// Parse piece symbol to Role enum
  /// Returns null if symbol is invalid
  static Role? parsePieceSymbol(String symbol) {
    switch (symbol.toUpperCase()) {
      case 'P':
        return Role.pawn;
      case 'R':
        return Role.rook;
      case 'N':
        return Role.knight;
      case 'B':
        return Role.bishop;
      case 'Q':
        return Role.queen;
      case 'K':
        return Role.king;
      default:
        return null;
    }
  }

  /// Create move notation with piece type: "Pe2e4", "Ne2f4", etc.
  static String createMoveNotation(Role pieceRole, String from, String to) {
    final pieceSymbol = getPieceSymbol(pieceRole);
    return '$pieceSymbol$from$to';
  }

  /// Parse move notation with piece type: "Pe2e4" -> (Role.pawn, "e2", "e4")
  /// Also handles old format without piece: "e2e4" -> (null, "e2", "e4")
  static Map<String, dynamic> parseMoveNotation(String notation) {
    if (notation.length == 4) {
      // Old format without piece: "e2e4"
      return {
        'piece': null,
        'from': notation.substring(0, 2),
        'to': notation.substring(2, 4),
      };
    } else if (notation.length == 5) {
      // New format with piece: "Pe2e4"
      final pieceSymbol = notation[0];
      final piece = parsePieceSymbol(pieceSymbol);
      return {
        'piece': piece,
        'from': notation.substring(1, 3),
        'to': notation.substring(3, 5),
      };
    }
    // Invalid format
    return {
      'piece': null,
      'from': '',
      'to': '',
    };
  }
}

