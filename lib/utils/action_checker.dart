import 'dart:math';

import 'package:chess_rps/common/enum.dart';
import 'package:chess_rps/model/board.dart';
import 'package:chess_rps/model/cell.dart';

class ActionChecker {
  static bool isVerticalActionAvailable(
      Board board, Cell from, Cell to, Side fromSide) {
    if (from.position.col != to.position.col) return false;
    if (from.position.row == to.position.row) return false;
    if (to.figure?.side != null && fromSide == to.figure!.side) return false;

    final minY = min(from.position.row, to.position.row);
    final maxY = max(from.position.row, to.position.row);

    for (int y = minY + 1; y < maxY; y++) {
      if (board.getCellAt(y, from.position.col).isOccupied) {
        return false;
      }
    }

    return true;
  }

  static bool isRookActionAvailable(
      Board board, Cell from, Cell to, Side fromSide) {
    return isVerticalActionAvailable(board, from, to, fromSide);
  }

  static Set<String> getAvailablePositionsHash(Board board, Cell? from) {
    final Set<String> availableCells = {};

    if (from == null || !from.isOccupied) return availableCells;

    for (int col = 0; col < cellsRowCount; col++) {
      for (int row = 0; row < cellsRowCount; row++) {
        final target = board.getCellAt(row, col);
        if (from.figure!.availableForMove(board, target)) {
          availableCells.add(target.positionHash);
        }
      }
    }

    return availableCells;
  }
}
