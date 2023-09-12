import 'package:chess_rps/common/enum.dart';
import 'package:chess_rps/model/board.dart';
import 'package:chess_rps/model/cell.dart';

abstract class Figure {
  final Side side;

  Cell cell;

  Figure({required this.side, required this.cell});

  void moveTo(Cell to);
  bool availableForMove(Board board, Cell to) {
    if (!to.isOccupied) {
      return true;
    }

    Figure occupiedFigure = to.figure!;

    if (occupiedFigure.side == side) {
      return false;
    }

    return true;
  }
}
