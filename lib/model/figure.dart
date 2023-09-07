import 'package:chess_rps/common/enum.dart';

abstract class Figure {
  Side get side;

  void moveTo();
  void possibleMoves();
}
