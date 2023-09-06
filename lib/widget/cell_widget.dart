import 'package:chess_rps/model/cell.dart';
import 'package:chess_rps/widget/custom/custom_gradient.dart';
import 'package:flutter/material.dart';

const String _imagesPath = 'assets/images/figures';

class CellWidget extends StatelessWidget {
  final Cell cell;

  const CellWidget({
    required this.cell,
    Key? key,
  }) : super(key: key);

  String get _appropriateImage {
    final side = cell.side.toString();
    final name = cell.figure!.runtimeType.toString().toLowerCase();

    return '$_imagesPath/$side/$name.png';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          // color: isEven ? Colors.black38 : Colors.white12,
          boxShadow: [
            BoxShadow(
              color: Colors.white.withOpacity(0.6),
              blurRadius: 4,
              blurStyle: BlurStyle.outer,
              offset: const Offset(1, 2),
            )
          ],
          borderRadius: BorderRadius.circular(4)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: CustomPaint(
          painter: CustomGradient(cellSide: cell.side),
          child: Stack(
            alignment: Alignment.center,
            children: [if (cell.figure != null) Image.asset(_appropriateImage)],
          ),
        ),
      ),
    );
  }
}
