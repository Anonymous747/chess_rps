import 'package:chess_rps/common/enum.dart';
import 'package:chess_rps/model/board.dart';
import 'package:chess_rps/model/cell.dart';
import 'package:chess_rps/model/position.dart';

abstract class Figure {
  final Side side;

  Position position;

  Figure({required this.side, required this.position});

  void moveTo(Cell to) {
    position = to.position;
  }

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
