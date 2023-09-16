import 'package:chess_rps/common/enum.dart';
import 'package:chess_rps/model/board.dart';
import 'package:chess_rps/model/cell.dart';
import 'package:chess_rps/model/figure.dart';
import 'package:chess_rps/model/position.dart';
import 'package:chess_rps/utils/action_checker.dart';

class Queen extends Figure {
  Queen({
    required Side side,
    required Position position,
  }) : super(
          position: position,
          side: side,
        );

  @override
  void moveTo(Cell to) {
    // TODO: implement moveTo
  }

  @override
  bool availableForMove(Board board, Cell to) {
    return _isQueenActionAvailable(board, to);
  }

  bool _isQueenActionAvailable(Board board, Cell to) {
    if (ActionChecker.isVerticalActionAvailable(board, position, to, side)) {
      return true;
    }
    if (ActionChecker.isHorizontalActionAvailable(board, position, to, side)) {
      return true;
    }
    if (ActionChecker.isDiagonalActionAvailable(board, position, to, side)) {
      return true;
    }

    return false;
  }
}
