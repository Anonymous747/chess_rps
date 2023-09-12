import 'package:chess_rps/common/enum.dart';
import 'package:chess_rps/model/board.dart';
import 'package:chess_rps/model/cell.dart';
import 'package:chess_rps/model/figure.dart';

class Queen extends Figure {
  Queen({
    required Side side,
    required Cell cell,
  }) : super(cell: cell, side: side);

  @override
  void moveTo(Cell to) {
    // TODO: implement moveTo
  }

  @override
  bool availableForMove(Board board, Cell to) {
    // TODO: implement possibleMoves
    return true;
  }
}
