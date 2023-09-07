import 'package:chess_rps/common/enum.dart';
import 'package:chess_rps/model/figure.dart';

class Queen implements Figure {
  final Side _side;

  const Queen(this._side);

  @override
  Side get side => _side;

  @override
  void moveTo() {
    // TODO: implement moveTo
  }

  @override
  void possibleMoves() {
    // TODO: implement possibleMoves
  }
}
