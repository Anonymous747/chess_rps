import 'package:chess_rps/common/enum.dart';
import 'package:chess_rps/model/cell.dart';
import 'package:chess_rps/model/figures/pawn.dart';

const cellsRowCount = 8;

class Board {
  List<List<Cell>> cells = [];

  List<Cell> lostLightFigures = [];
  List<Cell> lostDarkFigures = [];

  void startGame() {
    _fillEmptyCells();
    _fillPawns();
  }

  void _fillEmptyCells() {
    for (int i = 0; i < cellsRowCount; i++) {
      var row = <Cell>[];

      for (int j = 0; j < cellsRowCount; j++) {
        final isEven = (i + j + 1) % 2 == 0;
        final side = isEven ? Side.light : Side.dark;

        row.add(Cell(side: side));
      }

      cells.add(row);
    }
  }

  void _fillPawns() {
    final rows = [1, 6];

    for (final row in rows) {
      for (int i = 0; i < cellsRowCount; i++) {
        cells[row][i].figure = Pawn();
      }
    }
  }
}
