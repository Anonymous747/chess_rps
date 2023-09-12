import 'package:chess_rps/common/enum.dart';
import 'package:chess_rps/model/board.dart';
import 'package:chess_rps/model/cell.dart';
import 'package:chess_rps/model/figure.dart';
import 'package:chess_rps/utils/action_checker.dart';

class Rook extends Figure {
  Rook({
    required Side side,
    required Cell cell,
  }) : super(side: side, cell: cell);

  @override
  void moveTo(Cell to) {
    // TODO: implement moveTo
  }

  @override
  bool availableForMove(Board board, Cell to) {
    return ActionChecker.isRookActionAvailable(board, cell, to, side);
  }
}
