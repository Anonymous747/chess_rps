import 'package:chess_rps/common/enum.dart';
import 'package:chess_rps/model/figure.dart';

class Knight implements Figure {
  final Side _side;

  const Knight(this._side);

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
