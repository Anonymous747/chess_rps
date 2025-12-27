import 'package:chess_rps/common/enum.dart';
import 'package:chess_rps/common/extension.dart';
import 'package:chess_rps/common/palette.dart';
import 'package:chess_rps/domain/model/cell.dart';
import 'package:chess_rps/domain/model/position.dart';
import 'package:chess_rps/presentation/controller/game_controller.dart';
import 'package:chess_rps/presentation/controller/settings_controller.dart';
import 'package:chess_rps/presentation/state/game_state.dart';
import 'package:chess_rps/presentation/utils/piece_pack_utils.dart';
import 'package:chess_rps/presentation/utils/board_theme_utils.dart';
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

  String _getAppropriateImage(Cell cell, String pieceSet) {
    final side = cell.figure!.side.toString();
    final name = cell.figure!.runtimeType.toString().toLowerCase();
    
    // Ensure pieceSet is not empty
    final safePieceSet = pieceSet.isNotEmpty ? pieceSet : 'cardinal';

    return '$_imagesPath/$safePieceSet/$side/$name.png';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cell = ref.watch(gameControllerProvider
        .select((state) => state.board.getCellAt(row, column)));
    final kingInCheck = ref.watch(gameControllerProvider
        .select((state) => state.kingInCheck));
    final controller = ref.watch(gameControllerProvider.notifier);
    final gameState = ref.watch(gameControllerProvider);
    final settingsAsync = ref.watch(settingsControllerProvider);
    
    // Check if this cell is part of the last move
    final lastMovePositions = gameState.getLastMovePositions();
    final isLastMoveFrom = lastMovePositions != null &&
        lastMovePositions['fromRow'] == row &&
        lastMovePositions['fromCol'] == column;
    final isLastMoveTo = lastMovePositions != null &&
        lastMovePositions['toRow'] == row &&
        lastMovePositions['toCol'] == column;
    final isLastMove = isLastMoveFrom || isLastMoveTo;
    
    // Get piece set from settings, validate it exists, fallback to default (cardinal)
    String pieceSet = 'cardinal'; // Default fallback
    if (settingsAsync.hasValue && settingsAsync.value != null) {
      final requestedPieceSet = settingsAsync.value!.pieceSet;
      if (requestedPieceSet.isNotEmpty) {
        final knownPacks = PiecePackUtils.getKnownPiecePacks();
        pieceSet = knownPacks.contains(requestedPieceSet) 
            ? requestedPieceSet 
            : 'cardinal';
      }
    }
    
    // Get board theme from settings, validate it exists, fallback to default
    final requestedBoardTheme = settingsAsync.valueOrNull?.boardTheme ?? 'glass_dark';
    final knownThemes = BoardThemeUtils.getKnownBoardThemes();
    final boardTheme = knownThemes.contains(requestedBoardTheme)
        ? requestedBoardTheme
        : 'glass_dark'; // Default to glass_dark if invalid
    
    // Check if this cell contains a king that is in check
    final isKingInCheck = cell.figure != null &&
        cell.figure!.role == Role.king &&
        kingInCheck != null &&
        cell.figure!.side == kingInCheck;

    return GestureDetector(
      onTap: () async {
        // Check if we're about to make a move and if confirm moves is enabled
        final settingsAsync = ref.read(settingsControllerProvider);
        final shouldConfirm = settingsAsync.valueOrNull?.confirmMoves ?? false;
        
        // Check if this tap would result in a move (has selected figure and this is a valid target)
        final wouldMakeMove = gameState.selectedFigure != null &&
            (cell.isAvailable || cell.canBeKnockedDown);
        
        if (shouldConfirm && wouldMakeMove) {
          // Show confirmation dialog
          final selectedPos = gameState.selectedFigure!.toPosition();
          final selectedCell = gameState.board.getCellAt(selectedPos.row, selectedPos.col);
          final fromPos = selectedCell.position;
          final toPos = cell.position;
          final action = '${fromPos.algebraicPosition}${toPos.algebraicPosition}';
          
          final confirmed = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              backgroundColor: Palette.backgroundTertiary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: Palette.glassBorder),
              ),
              title: Text(
                'Confirm Move',
                style: TextStyle(color: Palette.textPrimary),
              ),
              content: Text(
                'Execute move: $action?',
                style: TextStyle(color: Palette.textSecondary),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text('Cancel', style: TextStyle(color: Palette.textSecondary)),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: Text('Confirm', style: TextStyle(color: Palette.purpleAccent)),
                ),
              ],
            ),
          );
          
          if (confirmed != true) {
            return; // User cancelled
          }
        }
        
        await controller.onPressed(cell);
      },
      child: Container(
        decoration: BoxDecoration(boxShadow: [
          BoxShadow(
            color: Colors.white.withValues(alpha: 0.6),
            blurRadius: 4,
            blurStyle: BlurStyle.outer,
            offset: const Offset(1, 2),
          )
        ], borderRadius: BorderRadius.circular(4)),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(6),
            child: CustomPaint(
              painter: CustomGradient(cellSide: cell.side, boardTheme: boardTheme),
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
                    backgroundColor: Palette.error.withValues(alpha: 0.3),
                  ),
                // Highlight last move - show a glowing border
                if (isLastMove)
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Palette.accent,
                        width: 3,
                      ),
                      borderRadius: BorderRadius.circular(4),
                      boxShadow: [
                        BoxShadow(
                          color: Palette.accent.withValues(alpha: 0.6),
                          blurRadius: 12,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                  ),
                if (cell.figure != null)
                  Container(
                    key: const ValueKey('figureKey'),
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage(_getAppropriateImage(cell, pieceSet)),
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
