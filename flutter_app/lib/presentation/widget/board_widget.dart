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
    final letters =
        PlayerSideMediator.playerSide.isLight ? boardLetters : boardLetters.reversed.toList();

    final numbers =
        PlayerSideMediator.playerSide.isLight ? boardNumbers : boardNumbers.reversed.toList();

    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
              color: Palette.backgroundTertiary,
              border: Border.all(width: _parentBorderWidth, color: Palette.backgroundTertiary),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Palette.black50,
                  blurRadius: 30,
                  spreadRadius: 0,
                  offset: const Offset(0, 15),
                ),
              ]),
          height: width - 30,
          width: width,
          child: Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
                color: Palette.backgroundElevated,
                border: Border.all(width: _childBorderWidth, color: Palette.glassBorder),
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
    final isBlackPlayer = !PlayerSideMediator.playerSide.isLight;

    // Build cells with proper rotation for black players
    // GridView.count fills cells left-to-right, top-to-bottom in the order we provide
    // 
    // Board layout (internal coordinates):
    // - Row 0-1: opponent pieces (white if player is black, black if player is white)
    // - Row 6-7: player pieces (black if player is black, white if player is white)
    //
    // For white: standard order (row 0 at visual top, row 7 at visual bottom)
    // For black: rotated 180 degrees
    //   - White pieces (row 0-1) should appear at visual top
    //   - Black pieces (row 6-7) should appear at visual bottom
    //   - Columns should be reversed (h-a from left to right)
    //
    // To achieve this for black:
    // - Iterate rows 0→7 (so row 0 goes first → visual top, row 7 goes last → visual bottom)
    // - Within each row, iterate columns 7→0 (so col 7 goes first → visual left, which is black's h-file)
    
    if (isBlackPlayer) {
      // For black: rotated view with columns reversed
      // Board layout: row 0-1 (white pieces), row 6-7 (black pieces)
      // User wants: black pieces at visual bottom, white pieces at visual top
      // 
      // Iterate rows 0→7 (so row 0 goes first → visual top, row 7 goes last → visual bottom)
      // Within each row, iterate columns 7→0 (so col 7 goes first → visual left, which is h-file)
      // This ensures:
      // - White pieces (row 0-1) appear at visual top
      // - Black pieces (row 6-7) appear at visual bottom
      // - Columns are reversed: h-a from left to right
      for (int i = 0; i < cells.length; i++) {
        for (int j = cells[i].length - 1; j >= 0; j--) {
          widgets.add(CellWidget(
            column: j,
            row: i,
          ));
        }
      }
    } else {
      // For white: standard order (top-left to bottom-right)
      for (int i = 0; i < cells.length; i++) {
        for (int j = 0; j < cells[i].length; j++) {
          widgets.add(CellWidget(
            column: j,
            row: i,
          ));
        }
      }
    }

    return widgets;
  }

  double _calculateCellWidth(BuildContext context, double width) =>
      (width - _parentBorderWidth * 2 - _childBorderWidth * 2) / 8 - 4;
}
