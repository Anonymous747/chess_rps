import 'package:chess_rps/common/palette.dart';
import 'package:chess_rps/domain/model/board.dart';
import 'package:chess_rps/presentation/mediator/player_side_mediator.dart';
import 'package:chess_rps/presentation/widget/cell_widget.dart';
import 'package:chess_rps/presentation/widget/collection/letters_collection.dart';
import 'package:chess_rps/presentation/widget/collection/numbers_column.dart';
import 'package:flutter/material.dart';

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

    final sideSize = _calculateCellWidth(context, width);
    final letters = PlayerSideMediator.playerSide.isLight
        ? boardLetters
        : boardLetters.reversed.toList();

    final numbers = PlayerSideMediator.playerSide.isLight
        ? boardNumbers
        : boardNumbers.reversed.toList();

    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
              color: Palette.backgroundTertiary,
              border: Border.all(
                  width: _parentBorderWidth, color: Palette.backgroundTertiary),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Palette.black50,
                  blurRadius: 30,
                  spreadRadius: 0,
                  offset: const Offset(0, 15),
                ),
              ]),
          height: width,
          width: width,
          child: Container(
            decoration: BoxDecoration(
                color: Palette.backgroundElevated,
                border: Border.all(
                    width: _childBorderWidth, color: Palette.glassBorder),
                borderRadius: BorderRadius.circular(16)),
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
            letters: letters,
            cellWidth: sideSize,
          ),
        ),
        Positioned(
          left: _parentBorderWidth + _childBorderWidth,
          bottom: 4,
          child: LettersCollection(
            letters: letters,
            cellWidth: sideSize,
          ),
        ),
        Positioned(
          top: _parentBorderWidth + _childBorderWidth,
          left: 6,
          child: NumbersColumn(
            letters: numbers,
            cellHeight: sideSize,
          ),
        ),
        Positioned(
          top: _parentBorderWidth + _childBorderWidth,
          right: 6,
          child: NumbersColumn(
            letters: numbers,
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
          column: j,
          row: i,
        ));
      }
    }

    return widgets;
  }

  double _calculateCellWidth(BuildContext context, double width) =>
      (width - _parentBorderWidth * 2 - _childBorderWidth * 2) / 8;
}
