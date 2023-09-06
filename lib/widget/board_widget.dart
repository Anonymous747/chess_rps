import 'package:chess_rps/common/palette.dart';
import 'package:chess_rps/model/board.dart';
import 'package:chess_rps/widget/cell_widget.dart';
import 'package:chess_rps/widget/collection/letters_collection.dart';
import 'package:chess_rps/widget/collection/numbers_column.dart';
import 'package:flutter/material.dart';

const _letters = ['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h'];
const _numbers = ['8', '7', '6', '5', '4', '3', '2', '1'];

const double _parentBorderWidth = 20;
const double _childBorderWidth = 6;

class BoardWidget extends StatelessWidget {
  final Board board;

  const BoardWidget({
    required this.board,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    final sideSize = _calculateCellWidth(context);

    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
              color: Palette.brown600,
              border: Border.all(
                  width: _parentBorderWidth, color: Palette.brown600),
              borderRadius: BorderRadius.circular(6)),
          height: width,
          width: width,
          child: Container(
            decoration: BoxDecoration(
                color: Palette.brown400,
                border: Border.all(
                    width: _childBorderWidth, color: Palette.brown400),
                borderRadius: BorderRadius.circular(6)),
            child: GridView.count(
              crossAxisCount: 8,
              children: _buildCells(),
            ),
          ),
        ),
        Positioned(
          left: _parentBorderWidth + _childBorderWidth,
          top: 2,
          child: LettersCollection(
            letters: _letters,
            cellWidth: sideSize,
          ),
        ),
        Positioned(
          left: _parentBorderWidth + _childBorderWidth,
          bottom: 4,
          child: LettersCollection(
            letters: _letters,
            cellWidth: sideSize,
          ),
        ),
        Positioned(
          top: _parentBorderWidth + _childBorderWidth,
          left: 6,
          child: NumbersColumn(
            letters: _numbers,
            cellHeight: sideSize,
          ),
        ),
        Positioned(
          top: _parentBorderWidth + _childBorderWidth,
          right: 6,
          child: NumbersColumn(
            letters: _numbers,
            cellHeight: sideSize,
          ),
        ),
      ],
    );
  }

  List<Widget> _buildCells() {
    final cells = board.cells;
    var widgets = <Widget>[];

    for (int i = 0; i < cells.length; i++) {
      for (int j = 0; j < cells[i].length; j++) {
        widgets.add(CellWidget(
          cell: board.cells[i][j],
        ));
      }
    }

    return widgets;
  }

  double _calculateCellWidth(BuildContext context) =>
      (MediaQuery.of(context).size.width -
          _parentBorderWidth * 2 -
          _childBorderWidth * 2) /
      8;
}
