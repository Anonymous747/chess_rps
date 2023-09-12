import 'package:chess_rps/controller/game_controller.dart';
import 'package:chess_rps/model/cell.dart';
import 'package:chess_rps/widget/custom/custom_gradient.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

const String _imagesPath = 'assets/images/figures';

class CellWidget extends HookConsumerWidget {
  // final Cell cell;
  final int column;
  final int row;

  const CellWidget({
    required this.column,
    required this.row,
    Key? key,
  }) : super(key: key);

  String _getAppropriateImage(Cell cell) {
    final side = cell.figure!.side.toString();
    final name = cell.figure!.runtimeType.toString().toLowerCase();

    return '$_imagesPath/$side/$name.png';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = ref.watch(gameControllerProvider.notifier);
    final cell = ref.watch(
        gameControllerProvider.select((board) => board.cells[row][column]));

    return GestureDetector(
      onTap: cell.figure != null
          ? () => provider.showAvailableActions(cell)
          : () {},
      child: Container(
        decoration: BoxDecoration(boxShadow: [
          BoxShadow(
            color: Colors.white.withOpacity(0.6),
            blurRadius: 4,
            blurStyle: BlurStyle.outer,
            offset: const Offset(1, 2),
          )
        ], borderRadius: BorderRadius.circular(4)),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: CustomPaint(
            painter: CustomGradient(cellSide: cell.side),
            child: Stack(
              children: [
                if (cell.figure != null)
                  Image.asset(_getAppropriateImage(cell)),
                if (cell.isSelected) const Text('Selected'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
