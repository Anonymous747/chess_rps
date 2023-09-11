import 'package:chess_rps/common/enum.dart';
import 'package:chess_rps/model/cell.dart';
import 'package:chess_rps/model/figures/bishop.dart';
import 'package:chess_rps/model/figures/king.dart';
import 'package:chess_rps/model/figures/knight.dart';
import 'package:chess_rps/model/figures/pawn.dart';
import 'package:chess_rps/model/figures/queen.dart';
import 'package:chess_rps/model/figures/rook.dart';

const cellsRowCount = 8;

class Board {
  List<List<Cell>> cells = [];
  List<Cell> lostLightFigures = [];
  List<Cell> lostDarkFigures = [];

  void startGame() {
    _fillEmptyCells();
    _fillPawns();
    _fillRook();
    _fillKnight();
    _fillBishops();
    _fillQueen();
    _fillKing();
  }

  void _fillEmptyCells() {
    for (int i = 0; i < cellsRowCount; i++) {
      var row = <Cell>[];

      for (int j = 0; j < cellsRowCount; j++) {
        final isEven = (i + j + 1) % 2 == 0;
        final side = isEven ? Side.light : Side.dark;

        row.add(Cell(side: side, row: i, column: j));
      }

      cells.add(row);
    }
  }

  void _fillPawns() {
    final rows = [1, 6];

    Side side = Side.dark;
    for (final row in rows) {
      for (int i = 0; i < cellsRowCount; i++) {
        cells[row][i].figure = Pawn(side);
      }

      side = Side.light;
    }
  }

  void _fillRook() {
    cells[0][0].figure = const Rook(Side.dark);
    cells[0][7].figure = const Rook(Side.dark);
    cells[7][0].figure = const Rook(Side.light);
    cells[7][7].figure = const Rook(Side.light);
  }

  void _fillKnight() {
    cells[0][1].figure = const Knight(Side.dark);
    cells[0][6].figure = const Knight(Side.dark);
    cells[7][1].figure = const Knight(Side.light);
    cells[7][6].figure = const Knight(Side.light);
  }

  void _fillBishops() {
    cells[0][2].figure = const Bishop(Side.dark);
    cells[0][5].figure = const Bishop(Side.dark);
    cells[7][2].figure = const Bishop(Side.light);
    cells[7][5].figure = const Bishop(Side.light);
  }

  void _fillQueen() {
    cells[0][3].figure = const Queen(Side.dark);
    cells[7][4].figure = const Queen(Side.light);
  }

  void _fillKing() {
    cells[0][4].figure = const King(Side.dark);
    cells[7][3].figure = const King(Side.light);
  }
}
