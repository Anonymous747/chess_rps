import 'package:chess_rps/common/enum.dart';
import 'package:chess_rps/domain/model/board.dart';
import 'package:chess_rps/domain/model/cell.dart';
import 'package:chess_rps/domain/model/figure.dart';
import 'package:chess_rps/domain/model/position.dart';
import 'package:chess_rps/presentation/utils/action_checker.dart';

class Queen extends Figure {
  Queen({
    required Side side,
    required Position position,
  }) : super(
          position: position,
          side: side,
          role: Role.queen,
        );

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

  @override
  Figure copyWith({Side? side, Position? position}) {
    return Queen(
      side: side ?? this.side,
      position: position ?? this.position,
    );
  }
}
