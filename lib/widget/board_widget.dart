import 'package:chess_rps/common/palette.dart';
import 'package:chess_rps/widget/cell_widget.dart';
import 'package:flutter/material.dart';

class BoardWidget extends StatelessWidget {
  const BoardWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    List<Widget> _buildCells() {
      final cells = <Widget>[];

      for (int i = 0; i < 8; i++) {
        for (int j = 0; j < 8; j++) {
          final isEven = (i + j + 1) % 2 == 0;

          cells.add(CellWidget(isEven: isEven));
        }
      }

      return cells;
    }

    return Container(
        margin: EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Palette.brown400,
        ),
        height: width - 20,
        width: width,
        child: GridView.count(
          crossAxisCount: 8,
          children: _buildCells(),
        ));
  }
}
