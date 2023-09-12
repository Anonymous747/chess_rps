import 'package:chess_rps/common/enum.dart';
import 'package:chess_rps/model/cell.dart';

abstract class Figure {
  Side get side;

  void moveTo(Cell to);
  bool availableForMove(Cell to) {
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
