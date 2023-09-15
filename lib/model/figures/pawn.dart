import 'package:chess_rps/common/enum.dart';
import 'package:chess_rps/model/board.dart';
import 'package:chess_rps/model/cell.dart';
import 'package:chess_rps/model/figure.dart';
import 'package:chess_rps/utils/action_checker.dart';

class Pawn extends Figure {
  bool _canDoubleMove = true;

  Pawn({
    required Side side,
    required Cell cell,
  }) : super(cell: cell, side: side);

  @override
  void moveTo(Cell to) {
    super.moveTo(to);

    _canDoubleMove = false;
  }

  @override
  bool availableForMove(Board board, Cell to) {
    return ActionChecker.isPawnActionAvailable(
      board,
      cell,
      to,
      side,
      canDoubleMove: _canDoubleMove,
    );
  }
}
