import 'package:chess_rps/common/palette.dart';
import 'package:chess_rps/domain/model/board.dart';
import 'package:chess_rps/domain/model/figure.dart';
import 'package:flutter/material.dart';

class CapturedPiecesWidget extends StatelessWidget {
  final Board board;
  final bool isLightSide;

  const CapturedPiecesWidget({
    required this.board,
    required this.isLightSide,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final capturedFigures = isLightSide
        ? board.lostDarkFigures
        : board.lostLightFigures;

    if (capturedFigures.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Palette.backgroundTertiary,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: Palette.glassBorder,
            width: 1,
          ),
        ),
        child: Text(
          'No captures',
          style: TextStyle(
            color: Palette.textTertiary,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Palette.backgroundTertiary,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Palette.glassBorder,
          width: 1,
        ),
      ),
      child: Wrap(
        spacing: 4,
        runSpacing: 4,
        children: capturedFigures.map((figure) {
          return _buildPieceIcon(figure);
        }).toList(),
      ),
    );
  }

  Widget _buildPieceIcon(Figure figure) {
    // Use same approach as cell_widget
    final side = figure.side.toString(); // Returns 'black' or 'white'
    final role = figure.role.toString().split('.').last.toLowerCase();
    final imagePath = 'assets/images/figures/$side/$role.png';

    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(imagePath),
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}

