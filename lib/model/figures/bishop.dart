import 'package:chess_rps/common/enum.dart';
import 'package:chess_rps/model/board.dart';
import 'package:chess_rps/model/cell.dart';
import 'package:chess_rps/model/figure.dart';
import 'package:chess_rps/model/position.dart';
import 'package:chess_rps/utils/action_checker.dart';

class Bishop extends Figure {
  Bishop({required Side side, required Position position})
      : super(
          position: position,
          side: side,
        );

  @override
  bool availableForMove(Board board, Cell to) {
    return _isBishopActionAvailable(board, to);
  }

  bool _isBishopActionAvailable(Board board, Cell to) {
    return ActionChecker.isDiagonalActionAvailable(board, position, to, side);
  }
}
