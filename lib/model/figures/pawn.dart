import 'package:chess_rps/common/enum.dart';
import 'package:chess_rps/model/board.dart';
import 'package:chess_rps/model/cell.dart';
import 'package:chess_rps/model/figure.dart';
import 'package:chess_rps/model/position.dart';

class Pawn extends Figure {
  bool _canDoubleMove = true;

  Pawn({
    required Side side,
    required Position position,
  }) : super(position: position, side: side);

  @override
  void moveTo(Cell to) {
    super.moveTo(to);

    _canDoubleMove = false;
  }

  @override
  bool availableForMove(Board board, Cell to) {
    return _isPawnActionAvailable(board, to);
  }

  bool _isTargetOccupied(Cell target) {
    if (target.isOccupied) {
      return target.isOccupied && side != target.figure!.side;
    }

    return false;
  }

  bool _isPawnActionAvailable(Board board, Cell to) {
    if (to.figure?.side != null && side == to.figure!.side) return false;

    final isDarkSide = side == Side.dark;
    final step = isDarkSide ? 1 : -1;
    final isStepCorrect = to.position.row == position.row + step;
    final isTargetOccupied =
        board.getCellAt(to.position.row, to.position.col).isOccupied;
    final isSameCol = to.position.col == position.col;

    if (isStepCorrect && to.position.col == position.col && !isTargetOccupied) {
      return true;
    }

    if (_canDoubleMove) {
      final doubleStep = isDarkSide ? 2 : -2;
      final isDoubleStepMatch = to.position.row == position.row + doubleStep;

      if (isDoubleStepMatch && isSameCol && !isTargetOccupied) {
        return true;
      }
    }

    final canKnockFromRight = to.position.col == position.col + 1;
    final canKnockFromLeft = to.position.col == position.col - 1;

    return isStepCorrect &&
        (canKnockFromLeft || canKnockFromRight) &&
        _isTargetOccupied(to);
  }
}
