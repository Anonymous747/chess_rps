import 'dart:math';

import 'package:chess_rps/common/enum.dart';
import 'package:chess_rps/model/board.dart';
import 'package:chess_rps/model/cell.dart';

class ActionChecker {
  static bool isVerticalActionAvailable(
      Board board, Cell from, Cell to, Side fromSide) {
    // Not available if on a different vertical side or in the same cell
    if (from.position.col != to.position.col ||
        from.position.row == to.position.row) return false;
    // If the cell is occupied by a figure of the same side
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

  static bool isHorizontalActionAvailable(
      Board board, Cell from, Cell to, Side fromSide) {
    // Not available if on a different horizontal side or in the same cell
    if (from.position.row != to.position.row ||
        from.position.col == to.position.col) return false;
    // If the cell is occupied by a figure of the same side
    if (to.figure?.side != null && fromSide == to.figure!.side) return false;

    final minX = min(from.position.col, to.position.col);
    final maxX = max(from.position.col, to.position.col);

    for (int x = minX + 1; x < maxX; x++) {
      if (board.getCellAt(from.position.row, x).isOccupied) {
        return false;
      }
    }

    return true;
  }

  static bool isDiagonalMoveAvailable(
      Board board, Cell from, Cell to, Side fromSide) {
    if (to.figure?.side != null && fromSide == to.figure!.side) return false;

    final absX = (to.position.col - from.position.col).abs();
    final absY = (to.position.row - from.position.row).abs();

    if (absX != absY) return false;

    final originY = from.position.row < to.position.row ? 1 : -1;
    final originX = from.position.col < to.position.col ? 1 : -1;

    for (int i = 1; i < absY; i++) {
      if (board
          .getCellAt(
              from.position.row + originY * i, from.position.col + originX * i)
          .isOccupied) {
        return false;
      }
    }

    return true;
  }

  static bool isRookActionAvailable(
      Board board, Cell from, Cell to, Side fromSide) {
    if (isVerticalActionAvailable(board, from, to, fromSide)) return true;
    if (isHorizontalActionAvailable(board, from, to, fromSide)) return true;

    return false;
  }

  static bool isQueenActionAvailable(
      Board board, Cell from, Cell to, Side fromSide) {
    if (isVerticalActionAvailable(board, from, to, fromSide)) return true;
    if (isHorizontalActionAvailable(board, from, to, fromSide)) return true;
    if (isDiagonalMoveAvailable(board, from, to, fromSide)) return true;

    return false;
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
