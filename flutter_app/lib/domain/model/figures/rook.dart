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
    bool isMoved = false,
  }) : super(
          side: side,
          position: position,
          role: Role.rook,
        ) {
    _isMoved = isMoved;
  }

  /// Did rook make moves (needed for castling rules)
  ///
  bool _isMoved = false;

  bool get hasMoved => _isMoved;

  @override
  void moveTo(Cell to) {
    super.moveTo(to);
    _isMoved = true;
  }

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

  @override
  Figure copyWith({Side? side, Position? position, bool? isMoved}) {
    return Rook(
      side: side ?? this.side,
      position: position ?? this.position,
      isMoved: isMoved ?? _isMoved,
    );
  }
}
