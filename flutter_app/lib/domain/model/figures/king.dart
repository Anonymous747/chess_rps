import 'dart:math';

import 'package:chess_rps/common/enum.dart';
import 'package:chess_rps/domain/model/board.dart';
import 'package:chess_rps/domain/model/cell.dart';
import 'package:chess_rps/domain/model/figure.dart';
import 'package:chess_rps/domain/model/position.dart';

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
    if (!_isMoved) {
      final isSameHorizontal = to.position.row == position.row;

      if (isSameHorizontal && !to.isOccupied) {
        final magnitudeToCell = magnitudeForPosition(to);

        if (magnitudeToCell > 2) return false;

        // Find the nearest rook to avoid unnecessary cycles
        final nearestRookX = to.getNearestRook();

        final minX = min(position.col, nearestRookX);
        final maxX = max(position.col, nearestRookX);

        bool isCastlingAvailable = true;
        for (int x = minX + 1; x < maxX; x++) {
          if (board.getCellAt(to.position.row, x).isOccupied) {
            isCastlingAvailable = false;
            break;
          }
        }

        if (isCastlingAvailable) return true;
      }
    }

    return magnitudeForPosition(to) == 1;
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
