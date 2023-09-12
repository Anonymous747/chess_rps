import 'package:chess_rps/model/board.dart';
import 'package:chess_rps/model/cell.dart';

class ActionChecker {
  static bool isVerticalActionAvailable(Board board, Cell from, Cell to) {
    return true;
  }

  static Set<String> getAvailablePositionsHash(Board board, Cell? from) {
    final Set<String> availableCells = {};

    if (from == null || !from.isOccupied) return availableCells;

    for (int row = 0; row < cellsRowCount; row++) {
      for (int col = 0; col < cellsRowCount; col++) {
        final target = board.getCellAt(col, row);
        if (from.figure!.availableForMove(target)) {
          availableCells.add(target.positionHash);
        }
      }
    }

    print('========= availableCells = $availableCells');

    return availableCells;
  }
}
