import 'package:chess_rps/common/enum.dart';
import 'package:chess_rps/model/cell.dart';
import 'package:chess_rps/model/figures/bishop.dart';
import 'package:chess_rps/model/figures/king.dart';
import 'package:chess_rps/model/figures/knight.dart';
import 'package:chess_rps/model/figures/pawn.dart';
import 'package:chess_rps/model/figures/queen.dart';
import 'package:chess_rps/model/figures/rook.dart';
import 'package:chess_rps/model/position.dart';

const cellsRowCount = 8;

class Board {
  List<List<Cell>> cells = [];
  List<Cell> lostLightFigures = [];
  List<Cell> lostDarkFigures = [];

  Cell getCellAt(int row, int col) {
    return cells[row][col];
  }

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

        row.add(Cell(side: side, position: Position(row: i, col: j)));
      }

      cells.add(row);
    }
  }

  void _fillPawns() {
    final rows = [1, 6];

    Side side = Side.dark;
    for (final row in rows) {
      for (int i = 0; i < cellsRowCount; i++) {
        cells[row][i] = cells[row][i]
            .copyWith(figure: Pawn(side: side, cell: getCellAt(row, i)));
      }

      side = Side.light;
    }

    cells[3][3] =
        cells[3][3].copyWith(figure: Pawn(side: side, cell: getCellAt(3, 3)));
  }

  void _fillRook() {
    cells[0][0] = cells[0][0]
        .copyWith(figure: Rook(side: Side.dark, cell: getCellAt(0, 0)));
    cells[0][7] = cells[0][7]
        .copyWith(figure: Rook(side: Side.dark, cell: getCellAt(0, 7)));
    cells[7][0] = cells[7][0]
        .copyWith(figure: Rook(side: Side.light, cell: getCellAt(7, 0)));
    cells[7][7] = cells[7][7]
        .copyWith(figure: Rook(side: Side.light, cell: getCellAt(7, 7)));
  }

  void _fillKnight() {
    cells[0][1] = cells[0][1]
        .copyWith(figure: Knight(side: Side.dark, cell: getCellAt(0, 1)));
    cells[0][6] = cells[0][6]
        .copyWith(figure: Knight(side: Side.dark, cell: getCellAt(0, 6)));
    cells[7][1] = cells[7][1]
        .copyWith(figure: Knight(side: Side.light, cell: getCellAt(7, 1)));
    cells[7][6] = cells[7][6]
        .copyWith(figure: Knight(side: Side.light, cell: getCellAt(7, 6)));
  }

  void _fillBishops() {
    cells[0][2] = cells[0][2]
        .copyWith(figure: Bishop(side: Side.dark, cell: getCellAt(0, 2)));
    cells[0][5] = cells[0][5]
        .copyWith(figure: Bishop(side: Side.dark, cell: getCellAt(0, 5)));
    cells[7][2] = cells[7][2]
        .copyWith(figure: Bishop(side: Side.light, cell: getCellAt(7, 2)));
    cells[7][5] = cells[7][5]
        .copyWith(figure: Bishop(side: Side.light, cell: getCellAt(7, 5)));
  }

  void _fillQueen() {
    cells[0][3] = cells[0][3]
        .copyWith(figure: Queen(side: Side.dark, cell: getCellAt(0, 3)));
    cells[7][4] = cells[7][4]
        .copyWith(figure: Queen(side: Side.light, cell: getCellAt(7, 4)));
  }

  void _fillKing() {
    cells[0][4] = cells[0][4]
        .copyWith(figure: King(side: Side.dark, cell: getCellAt(0, 4)));
    cells[7][3] = cells[7][3]
        .copyWith(figure: King(side: Side.light, cell: getCellAt(7, 3)));
  }
}
