import 'dart:math';

import 'package:chess_rps/common/enum.dart';
import 'package:chess_rps/model/board.dart';
import 'package:chess_rps/model/cell.dart';
import 'package:chess_rps/model/position.dart';

class ActionChecker {
  static bool isVerticalActionAvailable(
      Board board, Position fromPosition, Cell to, Side fromSide) {
    // Not available if on a different vertical side or in the same cell
    if (fromPosition.col != to.position.col ||
        fromPosition.row == to.position.row) return false;
    // If the cell is occupied by a figure of the same side
    if (to.figure?.side != null && fromSide == to.figure!.side) return false;

    final minY = min(fromPosition.row, to.position.row);
    final maxY = max(fromPosition.row, to.position.row);

    for (int y = minY + 1; y < maxY; y++) {
      if (board.getCellAt(y, fromPosition.col).isOccupied) {
        return false;
      }
    }

    return true;
  }

  static bool isHorizontalActionAvailable(
      Board board, Position fromPosition, Cell to, Side fromSide) {
    // Not available if on a different horizontal side or in the same cell
    if (fromPosition.row != to.position.row ||
        fromPosition.col == to.position.col) return false;
    // If the cell is occupied by a figure of the same side
    if (to.figure?.side != null && fromSide == to.figure!.side) return false;

    final minX = min(fromPosition.col, to.position.col);
    final maxX = max(fromPosition.col, to.position.col);

    for (int x = minX + 1; x < maxX; x++) {
      if (board.getCellAt(fromPosition.row, x).isOccupied) {
        return false;
      }
    }

    return true;
  }

  static bool isDiagonalActionAvailable(
      Board board, Position fromPosition, Cell to, Side fromSide) {
    if (to.figure?.side != null && fromSide == to.figure!.side) return false;

    final absX = (to.position.col - fromPosition.col).abs();
    final absY = (to.position.row - fromPosition.row).abs();

    if (absX != absY) return false;

    final originY = fromPosition.row < to.position.row ? 1 : -1;
    final originX = fromPosition.col < to.position.col ? 1 : -1;

    for (int i = 1; i < absY; i++) {
      if (board
          .getCellAt(
              fromPosition.row + originY * i, fromPosition.col + originX * i)
          .isOccupied) {
        return false;
      }
    }

    return true;
  }

  static Set<String> getAvailablePositionsHash(Board board, Cell? from) {
    final Set<String> availableCells = {};

    if (from == null || !from.isOccupied) return availableCells;

    for (int row = 0; row < cellsRowCount; row++) {
      for (int col = 0; col < cellsRowCount; col++) {
        final target = board.getCellAt(row, col);
        if (from.figure!.availableForMove(board, target)) {
          availableCells.add(target.positionHash);
        }
      }
    }

    return availableCells;
  }
}
