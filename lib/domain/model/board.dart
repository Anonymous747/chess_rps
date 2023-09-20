import 'package:chess_rps/common/enum.dart';
import 'package:chess_rps/domain/model/cell.dart';
import 'package:chess_rps/domain/model/figure.dart';
import 'package:chess_rps/domain/model/figures/bishop.dart';
import 'package:chess_rps/domain/model/figures/king.dart';
import 'package:chess_rps/domain/model/figures/knight.dart';
import 'package:chess_rps/domain/model/figures/pawn.dart';
import 'package:chess_rps/domain/model/figures/queen.dart';
import 'package:chess_rps/domain/model/figures/rook.dart';
import 'package:chess_rps/domain/model/position.dart';

const cellsRowCount = 8;

const boardLetters = ['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h'];
const boardNumbers = ['8', '7', '6', '5', '4', '3', '2', '1'];

class Board {
  List<List<Cell>> cells = [];

  List<Figure> lostLightFigures = [];
  List<Figure> lostDarkFigures = [];

  Cell getCellAt(int row, int col) {
    return cells[row][col];
  }

  void removeSelection() {
    for (int col = 0; col < cellsRowCount; col++) {
      for (int row = 0; row < cellsRowCount; row++) {
        final cell = getCellAt(row, col);

        if (cell.isAvailable || cell.isSelected || cell.canBeKnockedDown) {
          cells[row][col] = cell.copyWith(
            isAvailable: false,
            isSelected: false,
            canBeKnockedDown: false,
          );
        }
      }
    }
  }

  void pushKnockedFigure(Figure knockedFigure) {
    knockedFigure.side == Side.dark
        ? lostDarkFigures.add(knockedFigure)
        : lostLightFigures.add(knockedFigure);
  }

  void setFigure(Cell from, Cell to) {
    final fromRow = from.position.row;
    final fromCol = from.position.col;
    final toRow = to.position.row;
    final toCol = to.position.col;

    _updateCellFigure(toRow, toCol, from.figure);
    _updateCellFigure(fromRow, fromCol, null);
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

  void _updateCellFigure(int row, int col, Figure? figure) {
    cells[row][col] = cells[row][col].copyWith(figure: figure);
  }

  void _fillPawns() {
    final rows = [1, 6];

    Side side = Side.dark;
    for (final row in rows) {
      for (int i = 0; i < cellsRowCount; i++) {
        final cellRowI = cells[row][i];

        _updateCellFigure(
            row, i, Pawn(side: side, position: cellRowI.position));
      }

      side = Side.light;
    }
  }

  void _fillRook() {
    final cell0_0 = getCellAt(0, 0);
    final cell0_7 = getCellAt(0, 7);
    final cell7_0 = getCellAt(7, 0);
    final cell7_7 = getCellAt(7, 7);

    _updateCellFigure(0, 0, Rook(side: Side.dark, position: cell0_0.position));
    _updateCellFigure(0, 7, Rook(side: Side.dark, position: cell0_7.position));
    _updateCellFigure(7, 0, Rook(side: Side.light, position: cell7_0.position));
    _updateCellFigure(7, 7, Rook(side: Side.light, position: cell7_7.position));
  }

  void _fillKnight() {
    final cell0_1 = getCellAt(0, 1);
    final cell0_6 = getCellAt(0, 6);
    final cell7_1 = getCellAt(7, 1);
    final cell7_6 = getCellAt(7, 6);

    _updateCellFigure(
        0, 1, Knight(side: Side.dark, position: cell0_1.position));
    _updateCellFigure(
        0, 6, Knight(side: Side.dark, position: cell0_6.position));
    _updateCellFigure(
        7, 1, Knight(side: Side.light, position: cell7_1.position));
    _updateCellFigure(
        7, 6, Knight(side: Side.light, position: cell7_6.position));
  }

  void _fillBishops() {
    final cell0_2 = getCellAt(0, 2);
    final cell0_5 = getCellAt(0, 5);
    final cell7_2 = getCellAt(7, 2);
    final cell7_5 = getCellAt(7, 5);

    _updateCellFigure(
        0, 2, Bishop(side: Side.dark, position: cell0_2.position));
    _updateCellFigure(
        0, 5, Bishop(side: Side.dark, position: cell0_5.position));
    _updateCellFigure(
        7, 2, Bishop(side: Side.light, position: cell7_2.position));
    _updateCellFigure(
        7, 5, Bishop(side: Side.light, position: cell7_5.position));
  }

  void _fillQueen() {
    final cell0_3 = getCellAt(0, 3);
    final cell7_4 = getCellAt(7, 4);

    _updateCellFigure(0, 3, Queen(side: Side.dark, position: cell0_3.position));
    _updateCellFigure(
        7, 4, Queen(side: Side.light, position: cell7_4.position));
  }

  void _fillKing() {
    final cell0_4 = getCellAt(0, 4);
    final cell7_3 = getCellAt(7, 3);

    _updateCellFigure(0, 4, King(side: Side.dark, position: cell0_4.position));
    _updateCellFigure(7, 3, King(side: Side.light, position: cell7_3.position));
  }
}
