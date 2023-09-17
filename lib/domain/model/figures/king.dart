import 'package:chess_rps/common/enum.dart';
import 'package:chess_rps/domain/model/board.dart';
import 'package:chess_rps/domain/model/cell.dart';
import 'package:chess_rps/domain/model/figure.dart';
import 'package:chess_rps/domain/model/position.dart';

class King extends Figure {
  King({required Side side, required Position position})
      : super(position: position, side: side);

  @override
  void moveTo(Cell to) {
    super.moveTo(to);
  }

  @override
  bool availableForMove(Board board, Cell to) {
    return _isKingActionAvailable(board, to);
  }

  bool _isKingActionAvailable(Board board, Cell to) {
    if (to.figure?.side != null && side == to.figure!.side) return false;

    final v = Position(
        row: position.row - to.position.row,
        col: position.col - to.position.col);

    return v.magnitude == 1;
  }
}
