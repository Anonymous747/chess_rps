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

  void removeSelection() {
    for (int col = 0; col < cellsRowCount; col++) {
      for (int row = 0; row < cellsRowCount; row++) {
        final cell = getCellAt(row, col);

        if (cell.isAvailable || cell.isSelected) {
          cells[row][col] = cell.copyWith(
            isAvailable: false,
            isSelected: false,
          );
        }
      }
    }
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
        final cellRowI = cells[row][i];

        cells[row][i] =
            cellRowI.copyWith(figure: Pawn(side: side, cell: cellRowI));
      }

      side = Side.light;
    }
  }

  void _fillRook() {
    final cell0_0 = getCellAt(0, 0);
    final cell0_7 = getCellAt(0, 7);
    final cell7_0 = getCellAt(7, 0);
    final cell7_7 = getCellAt(7, 7);

    cells[0][0] =
        cell0_0.copyWith(figure: Rook(side: Side.dark, cell: cell0_0));
    cells[0][7] =
        cell0_7.copyWith(figure: Rook(side: Side.dark, cell: cell0_7));
    cells[7][0] =
        cell7_0.copyWith(figure: Rook(side: Side.light, cell: cell7_0));
    cells[7][7] =
        cell7_7.copyWith(figure: Rook(side: Side.light, cell: cell7_7));
  }

  void _fillKnight() {
    final cell0_1 = getCellAt(0, 1);
    final cell0_6 = getCellAt(0, 6);
    final cell7_1 = getCellAt(7, 1);
    final cell7_6 = getCellAt(7, 6);

    cells[0][1] =
        cell0_1.copyWith(figure: Knight(side: Side.dark, cell: cell0_1));
    cells[0][6] =
        cell0_6.copyWith(figure: Knight(side: Side.dark, cell: cell0_6));
    cells[7][1] =
        cell7_1.copyWith(figure: Knight(side: Side.light, cell: cell7_1));
    cells[7][6] =
        cell7_6.copyWith(figure: Knight(side: Side.light, cell: cell7_6));
  }

  void _fillBishops() {
    final cell0_2 = getCellAt(0, 2);
    final cell0_5 = getCellAt(0, 5);
    final cell7_2 = getCellAt(7, 2);
    final cell7_5 = getCellAt(7, 5);

    cells[0][2] =
        cell0_2.copyWith(figure: Bishop(side: Side.dark, cell: cell0_2));
    cells[0][5] =
        cell0_5.copyWith(figure: Bishop(side: Side.dark, cell: cell0_5));
    cells[7][2] =
        cell7_2.copyWith(figure: Bishop(side: Side.light, cell: cell7_2));
    cells[7][5] =
        cell7_5.copyWith(figure: Bishop(side: Side.light, cell: cell7_5));
  }

  void _fillQueen() {
    final cell0_3 = getCellAt(0, 3);
    final cell7_4 = getCellAt(7, 4);

    cells[0][3] =
        cell0_3.copyWith(figure: Queen(side: Side.dark, cell: cell0_3));
    cells[7][4] =
        cell7_4.copyWith(figure: Queen(side: Side.light, cell: cell7_4));
  }

  void _fillKing() {
    final cell0_4 = getCellAt(0, 4);
    final cell7_3 = getCellAt(7, 3);

    cells[0][4] =
        cell0_4.copyWith(figure: King(side: Side.dark, cell: cell0_4));
    cells[7][3] =
        cell7_3.copyWith(figure: King(side: Side.light, cell: cell7_3));
  }
}
