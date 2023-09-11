import 'package:chess_rps/common/enum.dart';
import 'package:chess_rps/model/cell.dart';

abstract class Figure {
  Side get side;

  void moveTo(Cell to);
  bool possibleMoves();
}
