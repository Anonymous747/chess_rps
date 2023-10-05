import 'package:chess_rps/common/enum.dart';
import 'package:chess_rps/domain/model/board.dart';
import 'package:chess_rps/domain/model/cell.dart';
import 'package:chess_rps/domain/model/figure.dart';
import 'package:chess_rps/domain/model/position.dart';

class Knight extends Figure {
  Knight({required Side side, required Position position})
      : super(side: side, position: position, role: Role.knight);

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

  @override
  Figure copyWith({Side? side, Position? position}) {
    return Knight(
      side: side ?? this.side,
      position: position ?? this.position,
    );
  }
}
