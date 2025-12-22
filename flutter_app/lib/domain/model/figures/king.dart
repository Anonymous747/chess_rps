import 'dart:math';

import 'package:chess_rps/common/enum.dart';
import 'package:chess_rps/domain/model/board.dart';
import 'package:chess_rps/domain/model/cell.dart';
import 'package:chess_rps/domain/model/figure.dart';
import 'package:chess_rps/domain/model/figures/rook.dart';
import 'package:chess_rps/domain/model/position.dart';
import 'package:chess_rps/presentation/utils/action_checker.dart';

class King extends Figure {
  King({required Side side, required Position position, bool isMoved = false})
      : super(position: position, side: side, role: Role.king) {
    _isMoved = isMoved;
  }

  /// Did king make moves
  ///
  bool _isMoved = false;

  @override
  void moveTo(Cell to) {
    super.moveTo(to);

    _isMoved = true;
  }

  @override
  bool availableForMove(Board board, Cell to) {
    return _isKingActionAvailable(board, to);
  }

  bool _isKingActionAvailable(Board board, Cell to) {
    if (to.figure?.side != null && side == to.figure!.side) return false;

    // Check if castling available
    if (!_isMoved && (position.col - to.position.col).abs() == 2 && position.row == to.position.row) {
      if (_isCastlingAvailable(board, to)) {
        return true;
      }
    }

    return magnitudeForPosition(to) == 1;
  }

  /// Check if castling is available according to chess rules
  /// Castling requirements:
  /// 1. King and rook must not have moved
  /// 2. King must not be in check
  /// 3. Squares between king and rook must be empty
  /// 4. King must not pass through check
  /// 5. King must not end up in check
  /// 6. Rook must be at the corner (col 0 or 7)
  bool _isCastlingAvailable(Board board, Cell to) {
    // Determine which side we're castling to (kingside or queenside)
    final isKingside = to.position.col > position.col;
    final rookCol = isKingside ? 7 : 0;
    final rookCell = board.getCellAt(position.row, rookCol);

    // 1. Check if rook exists, hasn't moved, and is at starting position
    if (rookCell.figure == null || 
        rookCell.figure!.role != Role.rook || 
        rookCell.figure!.side != side) {
      return false;
    }
    
    // Check if rook has moved (castling requires rook to be unmoved)
    final rook = rookCell.figure!;
    if (rook is Rook && rook.hasMoved) {
      return false;
    }

    // 2. Check if king is currently in check
    if (ActionChecker.isKingInCheck(board, side)) {
      return false;
    }

    // 3. Check if squares between king and rook are empty
    final minX = min(position.col, rookCol);
    final maxX = max(position.col, rookCol);
    for (int x = minX + 1; x < maxX; x++) {
      if (board.getCellAt(position.row, x).isOccupied) {
        return false;
      }
    }

    // 4. Check if squares the king moves through are under attack
    // King moves 2 squares, so check both the square it passes through and the final square
    final kingPassThroughCol = position.col + (isKingside ? 1 : -1);
    final kingFinalCol = to.position.col;
    
    // Check if the square the king passes through is under attack
    if (_isSquareUnderAttack(board, position.row, kingPassThroughCol, side)) {
      return false;
    }
    
    // 5. Check if the final square the king lands on is under attack
    if (_isSquareUnderAttack(board, position.row, kingFinalCol, side)) {
      return false;
    }

    return true;
  }

  /// Check if a square is under attack by opponent pieces
  /// This is used to verify castling squares are safe
  bool _isSquareUnderAttack(Board board, int row, int col, Side defendingSide) {
    final opponentSide = defendingSide.opposite;
    final targetCell = board.getCellAt(row, col);
    
    // Check if any opponent piece can attack this square
    for (int r = 0; r < 8; r++) {
      for (int c = 0; c < 8; c++) {
        final cell = board.getCellAt(r, c);
        if (cell.figure != null && cell.figure!.side == opponentSide) {
          // Check if this opponent piece can attack the target square
          if (cell.figure!.availableForMove(board, targetCell)) {
            return true;
          }
        }
      }
    }
    
    return false;
  }

  @override
  Figure copyWith({Side? side, Position? position}) {
    return King(
      side: side ?? this.side,
      position: position ?? this.position,
      isMoved: _isMoved,
    );
  }
}

extension KingExtension on Figure {
  /// Define magnitude between current point and some [to] point
  ///
  int magnitudeForPosition(Cell to) {
    final dif = Position(
        row: position.row - to.position.row,
        col: position.col - to.position.col);

    return dif.magnitude;
  }
}
