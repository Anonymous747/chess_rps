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
import 'package:chess_rps/presentation/mediator/player_side_mediator.dart';

const cellsRowCount = 8;

const boardLetters = ['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h'];
const boardNumbers = ['8', '7', '6', '5', '4', '3', '2', '1'];

class Board {
  /// Represent a state of board cells
  ///
  List<List<Cell>> cells = [];

  /// When the light player beat some figures, they appears here
  ///
  List<Figure> lostLightFigures = [];

  ///  When the dark player beat some figures, they appears here
  ///
  List<Figure> lostDarkFigures = [];

  /// Return cell from selected position
  ///
  Cell getCellAt(int row, int col) {
    return cells[row][col];
  }

  /// Remove all modifications from cells like [isAvailable], [isSelected] or
  /// [canBeKnockedDown]
  ///
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

  /// Add knocked figure to opponents pile
  ///
  void pushKnockedFigure(Figure knockedFigure) {
    knockedFigure.side.isLight
        ? lostLightFigures.add(knockedFigure)
        : lostDarkFigures.add(knockedFigure);
  }

  /// Execute from [from] cell to [to] cell
  /// Update state of [board]
  ///
  void makeMove(Cell from, Cell to) {
    if (from.figure == null) throw Exception("From cell figure can't be null");

    _updateCellFigure(
        to.row, to.col, from.figure!.copyWith(position: to.position));
    _updateCellFigure(from.row, from.col, null);

    if (from.figure!.role == Role.king && (from.col - to.col).abs() > 1) {
      _handleKingCastling(from, to);
    }
  }

  /// King castling mechanism
  ///
  void _handleKingCastling(Cell from, Cell to) {
    final nearestRookX = to.getNearestRook();
    final mediumX = from.col.compareTo(to.col) + to.col;
    final rook = getCellAt(from.row, nearestRookX)
        .figure!
        .copyWith(position: Position(row: from.row, col: mediumX));

    _updateCellFigure(from.row, mediumX, rook);
    _updateCellFigure(from.row, nearestRookX, null);
  }

  /// Method that initialize cells and define figure positions
  ///
  void startGame() {
    final playerSide = PlayerSideMediator.playerSide;

    _fillEmptyCells(playerSide);
    _defineFigurePositions(playerSide);
    _fillQueen(playerSide);
    _fillKing(playerSide);
  }

  /// Initialize board cells and paint them in light or dark depend on position
  ///
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
        0: [2, 3, 4, 0, 0, 4, 3, 2],
        1: [1, 1, 1, 1, 1, 1, 1, 1],
        6: [1, 1, 1, 1, 1, 1, 1, 1],
        7: [2, 3, 4, 0, 0, 4, 3, 2],
      };

  /// Setup figures to their positions according to [_figurePositions]
  ///
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
        }

        _updateCellFigure(row, col, figure);
      }
    }
  }

  /// Define correct position for queens
  ///
  void _fillQueen(Side playerSide) {
    const playerQueenRow = 0, opponentQueenRow = 7;
    final queenCol = PlayerSideMediator.playerSide.isLight ? 3 : 4;

    _updateCellFigure(
        playerQueenRow,
        queenCol,
        Queen(
            side: playerSide.opposite,
            position: getCellAt(playerQueenRow, queenCol).position));
    _updateCellFigure(
        opponentQueenRow,
        queenCol,
        Queen(
            side: playerSide,
            position: getCellAt(opponentQueenRow, queenCol).position));
  }

  /// Define correct position for kings
  ///
  void _fillKing(Side playerSide) {
    const playerKingRow = 0, opponentKingRow = 7;
    final kingCol = PlayerSideMediator.playerSide.isLight ? 4 : 3;

    _updateCellFigure(
        playerKingRow,
        kingCol,
        King(
            side: playerSide.opposite,
            position: getCellAt(playerKingRow, kingCol).position));
    _updateCellFigure(
        opponentKingRow,
        kingCol,
        King(
            side: playerSide,
            position: getCellAt(opponentKingRow, kingCol).position));
  }

  /// Shorter way to update cell's figure
  ///
  void _updateCellFigure(int row, int col, Figure? figure) {
    cells[row][col] = cells[row][col].copyWith(figure: figure);
  }

  /// Update needed to you cell on board more convenient
  ///
  void updateCell(int row, int col, Cell Function(Cell) updatedCell) {
    cells[row][col] = updatedCell(cells[row][col]);
  }
}
