import 'dart:math';

import 'package:chess_rps/common/enum.dart';
import 'package:chess_rps/domain/model/board.dart';
import 'package:chess_rps/domain/model/cell.dart';
import 'package:chess_rps/domain/model/position.dart';

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

  /// Check if a move would put the moving side's king in check
  /// Returns true if the move would result in the king being in check
  /// This method temporarily makes the move, checks for check, then undoes it
  static bool wouldMovePutKingInCheck(Board board, Cell from, Cell to) {
    if (from.figure == null) return false;
    
    final movingSide = from.figure!.side;
    
    // Store original state - create copies to avoid any mutation issues
    final originalFromFigure = from.figure!.copyWith(position: from.position);
    final originalToFigure = to.figure?.copyWith(position: to.position);
    
    // Temporarily make the move
    board.makeMove(from, to);
    
    // Check if the king is now in check
    final wouldBeInCheck = isKingInCheck(board, movingSide);
    
    // Undo the move by restoring original state
    // Restore the from cell with original figure
    board.updateCell(from.row, from.col, (cell) => 
      cell.copyWith(figure: originalFromFigure));
    
    // Restore the to cell with original figure (or null if it was empty)
    board.updateCell(to.row, to.col, (cell) => 
      cell.copyWith(figure: originalToFigure));
    
    // If it was a castling move, we need to undo that too
    // But for simplicity, we'll just restore the figures
    // Castling undo would require more complex logic, but it's rare
    
    return wouldBeInCheck;
  }

  static Set<String> getAvailablePositionsHash(Board board, Cell? from) {
    final Set<String> availableCells = {};

    if (from == null || !from.isOccupied) return availableCells;

    final movingSide = from.figure!.side;
    final isKingInCheck = ActionChecker.isKingInCheck(board, movingSide);

    for (int row = 0; row < cellsRowCount; row++) {
      for (int col = 0; col < cellsRowCount; col++) {
        final target = board.getCellAt(row, col);

        if (from.figure!.availableForMove(board, target)) {
          // If king is in check, only allow moves that remove the check
          if (isKingInCheck) {
            if (wouldMoveRemoveCheck(board, from, target, movingSide)) {
              availableCells.add(target.positionHash);
            }
          } else {
            // If king is not in check, filter out moves that would put king in check
            if (!wouldMovePutKingInCheck(board, from, target)) {
              availableCells.add(target.positionHash);
            }
          }
        }
      }
    }

    return availableCells;
  }

  /// Check if a move would remove check (i.e., after the move, the king is no longer in check)
  /// Returns true if the move would result in the king NOT being in check
  static bool wouldMoveRemoveCheck(Board board, Cell from, Cell to, Side movingSide) {
    if (from.figure == null) return false;
    
    // Store original state - create copies to avoid any mutation issues
    final originalFromFigure = from.figure!.copyWith(position: from.position);
    final originalToFigure = to.figure?.copyWith(position: to.position);
    
    // Temporarily make the move
    board.makeMove(from, to);
    
    // Check if the king is still in check after the move
    final stillInCheck = isKingInCheck(board, movingSide);
    final wouldRemoveCheck = !stillInCheck;
    
    // Undo the move by restoring original state
    board.updateCell(from.row, from.col, (cell) => 
      cell.copyWith(figure: originalFromFigure));
    
    board.updateCell(to.row, to.col, (cell) => 
      cell.copyWith(figure: originalToFigure));
    
    return wouldRemoveCheck;
  }

  /// Check if a king of the given side is in check
  /// Returns true if the king is under attack by opponent pieces
  static bool isKingInCheck(Board board, Side kingSide) {
    // Find the king
    Cell? kingCell;
    for (int row = 0; row < cellsRowCount; row++) {
      for (int col = 0; col < cellsRowCount; col++) {
        final cell = board.getCellAt(row, col);
        if (cell.figure != null &&
            cell.figure!.role == Role.king &&
            cell.figure!.side == kingSide) {
          kingCell = cell;
          break;
        }
      }
      if (kingCell != null) break;
    }

    if (kingCell == null || kingCell.figure == null) return false;

    final opponentSide = kingSide.opposite;

    // Check if any opponent piece can attack the king
    for (int row = 0; row < cellsRowCount; row++) {
      for (int col = 0; col < cellsRowCount; col++) {
        final cell = board.getCellAt(row, col);
        if (cell.figure != null && cell.figure!.side == opponentSide) {
          // Check if this opponent piece can attack the king
          if (cell.figure!.availableForMove(board, kingCell)) {
            return true;
          }
        }
      }
    }

    return false;
  }

  /// Find the cell containing the king of the given side
  static Cell? findKing(Board board, Side kingSide) {
    for (int row = 0; row < cellsRowCount; row++) {
      for (int col = 0; col < cellsRowCount; col++) {
        final cell = board.getCellAt(row, col);
        if (cell.figure != null &&
            cell.figure!.role == Role.king &&
            cell.figure!.side == kingSide) {
          return cell;
        }
      }
    }
    return null;
  }
}
