import 'dart:math';

import 'package:chess_rps/common/enum.dart';
import 'package:chess_rps/domain/model/board.dart';
import 'package:chess_rps/domain/model/cell.dart';
import 'package:chess_rps/domain/model/figure.dart';
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

    // 1. Check if rook exists and hasn't moved (rook must be at starting position)
    if (rookCell.figure == null || 
        rookCell.figure!.role != Role.rook || 
        rookCell.figure!.side != side) {
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

    // 4. Check if king passes through check (squares king moves through must not be under attack)
    // King moves 2 squares, so check the square it passes through
    final kingPassThroughCol = position.col + (isKingside ? 1 : -1);
    final passThroughCell = board.getCellAt(position.row, kingPassThroughCol);
    
    // Temporarily move king to pass-through square to check if it would be in check
    final originalKing = board.getCellAt(position.row, position.col).figure;
    board.updateCell(position.row, kingPassThroughCol, (cell) => 
      cell.copyWith(figure: originalKing?.copyWith(position: passThroughCell.position)));
    board.updateCell(position.row, position.col, (cell) => cell.copyWith(figure: null));
    
    final wouldBeInCheck = ActionChecker.isKingInCheck(board, side);
    
    // Restore king
    board.updateCell(position.row, position.col, (cell) => 
      cell.copyWith(figure: originalKing));
    board.updateCell(position.row, kingPassThroughCol, (cell) => cell.copyWith(figure: null));
    
    if (wouldBeInCheck) {
      return false;
    }

    // 5. Check if final position would put king in check
    final originalKingFinal = board.getCellAt(position.row, position.col).figure;
    board.updateCell(to.position.row, to.position.col, (cell) => 
      cell.copyWith(figure: originalKingFinal?.copyWith(position: to.position)));
    board.updateCell(position.row, position.col, (cell) => cell.copyWith(figure: null));
    
    final finalWouldBeInCheck = ActionChecker.isKingInCheck(board, side);
    
    // Restore king
    board.updateCell(position.row, position.col, (cell) => 
      cell.copyWith(figure: originalKingFinal));
    board.updateCell(to.position.row, to.position.col, (cell) => cell.copyWith(figure: null));
    
    if (finalWouldBeInCheck) {
      return false;
    }

    return true;
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
