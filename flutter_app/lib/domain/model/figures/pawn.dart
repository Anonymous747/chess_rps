import 'package:chess_rps/common/enum.dart';
import 'package:chess_rps/domain/model/board.dart';
import 'package:chess_rps/domain/model/cell.dart';
import 'package:chess_rps/domain/model/figure.dart';
import 'package:chess_rps/domain/model/position.dart';
import 'package:chess_rps/presentation/mediator/player_side_mediator.dart';

class Pawn extends Figure {
  bool _canDoubleMove;

  Pawn({
    required Side side,
    required Position position,
    bool canDoubleMove = true,
  }) : _canDoubleMove = canDoubleMove,
       super(position: position, side: side, role: Role.pawn);

  @override
  void moveTo(Cell to) {
    super.moveTo(to);

    _canDoubleMove = false;
  }

  @override
  bool availableForMove(Board board, Cell to) {
    return _isPawnActionAvailable(board, to);
  }

  bool _isTargetOccupied(Cell target) {
    if (target.isOccupied) {
      return target.isOccupied && side != target.figure!.side;
    }

    return false;
  }

  /// Check if pawn is on its starting row
  /// White pawns start at row 1 (from white's perspective)
  /// Black pawns start at row 6 (from white's perspective)
  /// In internal board: row 0-1 = opponent, row 6-7 = player
  bool _isOnStartingRow() {
    if (side == Side.light) {
      // White pawn: starting row depends on player side
      // If player is white: white pawns at row 6
      // If player is black: white pawns at row 0 (opponent)
      final playerSide = PlayerSideMediator.playerSide;
      return playerSide == Side.light ? position.row == 6 : position.row == 0;
    } else {
      // Black pawn: starting row depends on player side
      // If player is white: black pawns at row 1 (opponent)
      // If player is black: black pawns at row 6 (player)
      final playerSide = PlayerSideMediator.playerSide;
      return playerSide == Side.light ? position.row == 1 : position.row == 6;
    }
  }

  bool _isPawnActionAvailable(Board board, Cell to) {
    if (to.figure?.side != null && side == to.figure!.side) return false;

    final isOpponent = side != PlayerSideMediator.playerSide;
    final step = isOpponent ? 1 : -1;
    final isStepCorrect = to.position.row == position.row + step;
    final isTargetOccupied =
        board.getCellAt(to.position.row, to.position.col).isOccupied;
    final isSameCol = to.position.col == position.col;

    if (isStepCorrect && to.position.col == position.col && !isTargetOccupied) {
      return true;
    }

    // Pawn can only move two squares on its first move
    // Check both: the flag AND if pawn is on starting row
    final isOnStartingRow = _isOnStartingRow();
    if (_canDoubleMove && isOnStartingRow) {
      final doubleStep = isOpponent ? 2 : -2;
      final isDoubleStepMatch = to.position.row == position.row + doubleStep;

      if (isDoubleStepMatch && isSameCol && !isTargetOccupied) {
        // Check if the intermediate square is empty (pawn can't jump over pieces)
        final intermediateRow = position.row + step;
        final intermediateCell = board.getCellAt(intermediateRow, position.col);
        if (!intermediateCell.isOccupied) {
          return true;
        }
      }
    }

    final canKnockFromRight = to.position.col == position.col + 1;
    final canKnockFromLeft = to.position.col == position.col - 1;

    return isStepCorrect &&
        (canKnockFromLeft || canKnockFromRight) &&
        _isTargetOccupied(to);
  }

  @override
  Figure copyWith({Side? side, Position? position}) {
    return Pawn(
      side: side ?? this.side,
      position: position ?? this.position,
      canDoubleMove: _canDoubleMove, // Preserve the double move state
    );
  }
}
