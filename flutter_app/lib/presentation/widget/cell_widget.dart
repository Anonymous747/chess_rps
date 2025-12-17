import 'package:chess_rps/common/enum.dart';
import 'package:chess_rps/common/palette.dart';
import 'package:chess_rps/domain/model/cell.dart';
import 'package:chess_rps/presentation/controller/game_controller.dart';
import 'package:chess_rps/presentation/widget/custom/animated_border.dart';
import 'package:chess_rps/presentation/widget/custom/available_move.dart';
import 'package:chess_rps/presentation/widget/custom/custom_gradient.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

const String _imagesPath = 'assets/images/figures';

class CellWidget extends HookConsumerWidget {
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
    final cell = ref.watch(gameControllerProvider
        .select((state) => state.board.getCellAt(row, column)));
    final kingInCheck = ref.watch(gameControllerProvider
        .select((state) => state.kingInCheck));
    final controller = ref.watch(gameControllerProvider.notifier);
    
    // Check if this cell contains a king that is in check
    final isKingInCheck = cell.figure != null &&
        cell.figure!.role == Role.king &&
        kingInCheck != null &&
        cell.figure!.side == kingInCheck;

    return GestureDetector(
      onTap: () async => await controller.onPressed(cell),
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
              alignment: Alignment.center,
              children: [
                if (cell.canBeKnockedDown)
                  const AnimatedBorder(
                    beginColor: Palette.white200,
                    endColor: Palette.purple400,
                    backgroundColor: Palette.purple300,
                  ),
                if (cell.isSelected)
                  const AnimatedBorder(
                    beginColor: Palette.white200,
                    endColor: Palette.purple500,
                    backgroundColor: Palette.purple400,
                  ),
                if (isKingInCheck)
                  AnimatedBorder(
                    beginColor: Palette.error,
                    endColor: Palette.warning,
                    backgroundColor: Palette.error.withOpacity(0.3),
                  ),
                if (cell.figure != null)
                  Container(
                    key: const ValueKey('figureKey'),
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage(_getAppropriateImage(cell)),
                      ),
                    ),
                  ),
                if (cell.isAvailable)
                  AvailableMove(isAvailable: cell.isAvailable),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
