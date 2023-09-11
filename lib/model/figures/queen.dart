import 'package:chess_rps/common/enum.dart';
import 'package:chess_rps/model/cell.dart';
import 'package:chess_rps/model/figure.dart';

class Queen implements Figure {
  final Side _side;

  const Queen(this._side);

  @override
  Side get side => _side;

  @override
  void moveTo(Cell to) {
    // TODO: implement moveTo
  }

  @override
  bool possibleMoves() {
    // TODO: implement possibleMoves
    return true;
  }
}
