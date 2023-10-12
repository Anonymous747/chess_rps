import 'package:chess_rps/common/enum.dart';
import 'package:chess_rps/domain/model/board.dart';
import 'package:chess_rps/domain/model/figures/rook.dart';
import 'package:chess_rps/domain/model/position.dart';
import 'package:chess_rps/presentation/utils/action_checker.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late Board board = Board()..startGame();

  group('Vertical actions', () {
    const fromPosition = Position(row: 1, col: 1);

    test('Is not available as in other diagonal', () {
      final toCell = board.getCellAt(5, 2);
      final result = ActionChecker.isVerticalActionAvailable(
          board, fromPosition, toCell, Side.dark);

      expect(result, false);
    });

    test('Is not available as the same side figure located', () {
      final toCell = board.getCellAt(0, 1);
      final result = ActionChecker.isVerticalActionAvailable(
          board, fromPosition, toCell, Side.dark);

      expect(result, false);
    });

    test('Is available', () {
      final toCell = board.getCellAt(5, 1);

      final result = ActionChecker.isVerticalActionAvailable(
          board, fromPosition, toCell, Side.dark);

      expect(result, true);
    });
  });

  group('Horizontal actions', () {
    const row = 3, col = 3;
    final fromFigure =
        Rook(side: Side.light, position: const Position(row: row, col: col));
    final mockBoard = board;
    mockBoard.updateCell(row, col, (cell) => cell.copyWith(figure: fromFigure));

    test('Is not available as in other vertical', () {
      final toCell = mockBoard.getCellAt(row - 1, 5);
      final result = ActionChecker.isHorizontalActionAvailable(
          mockBoard, fromFigure.position, toCell, Side.light);

      expect(result, false);
    });

    test('Is not available as the same side figure located', () {
      final toFigure =
          Rook(side: Side.light, position: const Position(row: row, col: 5));
      mockBoard.updateCell(row, 5, (cell) => cell.copyWith(figure: toFigure));
      final toCell = mockBoard.getCellAt(row, 5);
      final result = ActionChecker.isHorizontalActionAvailable(
          mockBoard, fromFigure.position, toCell, Side.light);

      expect(result, false);
    });

    test('Is not available as until target some cell is occupied', () {
      final toCell = mockBoard.getCellAt(row, 6);
      final result = ActionChecker.isHorizontalActionAvailable(
          mockBoard, fromFigure.position, toCell, Side.light);

      expect(result, false);
    });

    test('Is available', () {
      final toCell = mockBoard.getCellAt(row, 4);
      final result = ActionChecker.isHorizontalActionAvailable(
          mockBoard, fromFigure.position, toCell, Side.light);

      expect(result, true);
    });
  });

  group('Diagonal actions', () {
    final fromCell = board.getCellAt(6, 1);
    final toCell = board.getCellAt(1, 6);

    test('Is available', () {
      final result = ActionChecker.isDiagonalActionAvailable(
          board, fromCell.position, toCell, fromCell.figure!.side);

      expect(result, true);
    });
  });
}
