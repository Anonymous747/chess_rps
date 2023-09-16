import 'package:chess_rps/common/enum.dart';
import 'package:chess_rps/model/board.dart';
import 'package:chess_rps/model/cell.dart';
import 'package:chess_rps/model/figure.dart';
import 'package:chess_rps/model/position.dart';

class Knight extends Figure {
  Knight({required Side side, required Position position})
      : super(side: side, position: position);

  @override
  bool availableForMove(Board board, Cell to) {
    return _isKnightActionAvailable(board, to);
  }

  bool _isKnightActionAvailable(Board board, Cell to) {
    if (to.figure?.side != null && side == to.figure!.side) return false;

    final absX = (position.col - to.position.col).abs();
    final absY = (position.row - to.position.row).abs();

    return absX == 2 && absY == 1 || absX == 1 && absY == 2;
  }
}
