import 'package:chess_rps/common/enum.dart';
import 'package:chess_rps/domain/model/board.dart';
import 'package:chess_rps/domain/model/cell.dart';
import 'package:chess_rps/domain/model/figure.dart';
import 'package:chess_rps/domain/model/position.dart';
import 'package:chess_rps/presentation/utils/action_checker.dart';

class Bishop extends Figure {
  Bishop({required Side side, required Position position})
      : super(
          position: position,
          side: side,
          role: Role.bishop,
        );

  @override
  bool availableForMove(Board board, Cell to) {
    return _isBishopActionAvailable(board, to);
  }

  bool _isBishopActionAvailable(Board board, Cell to) {
    return ActionChecker.isDiagonalActionAvailable(board, position, to, side);
  }

  @override
  Figure copyWith({Side? side, Position? position}) {
    return Bishop(
      side: side ?? this.side,
      position: position ?? this.position,
    );
  }
}
