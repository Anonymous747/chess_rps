import 'package:chess_rps/common/enum.dart';
import 'package:chess_rps/model/board.dart';
import 'package:chess_rps/model/cell.dart';
import 'package:chess_rps/model/figure.dart';
import 'package:chess_rps/model/position.dart';

class King extends Figure {
  King({required Side side, required Position position})
      : super(position: position, side: side);

  @override
  void moveTo(Cell to) {
    // TODO: implement moveTo
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
