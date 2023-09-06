import 'package:chess_rps/common/enum.dart';
import 'package:chess_rps/model/cell.dart';

const cellsRowCount = 8;

class Board {
  List<List<Cell>> cells = [];

  List<Cell> lostLightFigures = [];
  List<Cell> lostDarkFigures = [];

  void startGame() {
    _fillEmptyCells();
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
}
