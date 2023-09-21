import 'package:chess_rps/common/enum.dart';
import 'package:chess_rps/domain/model/board.dart';
import 'package:chess_rps/domain/model/cell.dart';
import 'package:chess_rps/domain/model/figure.dart';
import 'package:chess_rps/domain/model/position.dart';
import 'package:chess_rps/presentation/utils/action_checker.dart';

class Rook extends Figure {
  Rook({
    required Side side,
    required Position position,
  }) : super(
          side: side,
          position: position,
        );

  @override
  bool availableForMove(Board board, Cell to) {
    return _isRookActionAvailable(board, to);
  }

  bool _isRookActionAvailable(Board board, Cell to) {
    if (ActionChecker.isVerticalActionAvailable(board, position, to, side)) {
      return true;
    }
    if (ActionChecker.isHorizontalActionAvailable(board, position, to, side)) {
      return true;
    }

    return false;
  }
}
