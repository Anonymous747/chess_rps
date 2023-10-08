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
import 'package:chess_rps/presentation/utils/player_side_mediator.dart';

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

  void makeMove(Cell from, Cell to) {
    if (from.figure == null) throw Exception("From cell figure can't be null");

    final fromRow = from.position.row;
    final fromCol = from.position.col;
    final toRow = to.position.row;
    final toCol = to.position.col;

    _updateCellFigure(
        toRow, toCol, from.figure!.copyWith(position: to.position));
    _updateCellFigure(fromRow, fromCol, null);

    if (from.figure!.role == Role.king && (fromCol - toCol).abs() > 1) {
      final nearestRookX = to.getNearestRook();
      final mediumX = fromCol.compareTo(toCol) + toCol;
      final rook = getCellAt(fromRow, nearestRookX)
          .figure!
          .copyWith(position: Position(row: fromRow, col: mediumX));

      _updateCellFigure(fromRow, mediumX, rook);
      _updateCellFigure(fromRow, nearestRookX, null);
    }
  }

  void startGame() {
    final playerSide = PlayerSideMediator.playerSide;

    _fillEmptyCells(playerSide);
    _defineFigurePositions(playerSide);
  }

  void _fillEmptyCells(Side playerSide) {
    for (int i = 0; i < cellsRowCount; i++) {
      var row = <Cell>[];

      for (int j = 0; j < cellsRowCount; j++) {
        final isLight = (i + j + 1) % 2 != 0;
        final side = isLight ? Side.light : Side.dark;

        row.add(Cell(side: side, position: Position(row: i, col: j)));
      }

      cells.add(row);
    }
  }

  /// This is a projection of the original position of the board, where the position
  /// of the line corresponds to the number codes.
  /// 1 - Pawn
  /// 2 - Rook
  /// 3 - Knight
  /// 4 - Bishop
  /// 5 - Queen
  /// 6 - King
  ///
  static Map<int, List<int>> get _figurePositions => {
        0: [2, 3, 4, 6, 5, 4, 3, 2],
        1: [1, 1, 1, 1, 1, 1, 1, 1],
        6: [1, 1, 1, 1, 1, 1, 1, 1],
        7: [2, 3, 4, 6, 5, 4, 3, 2],
      };

  void _defineFigurePositions(Side playerSide) {
    for (final row in _figurePositions.keys) {
      for (int col = 0; col < _figurePositions[row]!.length; col++) {
        final figureSign = _figurePositions[row]![col];

        final side = row == 0 || row == 1 ? playerSide.opposite : playerSide;
        final position = Position(row: row, col: col);

        Figure? figure;
        switch (figureSign) {
          case 1:
            figure = Pawn(side: side, position: position);
            break;
          case 2:
            figure = Rook(side: side, position: position);
            break;
          case 3:
            figure = Knight(side: side, position: position);
            break;
          case 4:
            figure = Bishop(side: side, position: position);
            break;
          case 5:
            figure = Queen(side: side, position: position);
            break;
          case 6:
            figure = King(side: side, position: position);
            break;
        }

        _updateCellFigure(row, col, figure);
      }
    }
  }

  void _updateCellFigure(int row, int col, Figure? figure) {
    cells[row][col] = cells[row][col].copyWith(figure: figure);
  }

  /// Update needed to you cell on board more convenient
  ///
  void updateCell(int row, int col, Cell Function(Cell) updatedCell) {
    cells[row][col] = updatedCell(cells[row][col]);
  }
}
