import 'package:chess_rps/common/asset_url.dart';
import 'package:chess_rps/common/palette.dart';
import 'package:chess_rps/domain/model/board.dart';
import 'package:chess_rps/domain/model/figure.dart';
import 'package:chess_rps/presentation/controller/game_controller.dart';
import 'package:chess_rps/presentation/controller/settings_controller.dart';
import 'package:chess_rps/presentation/utils/piece_pack_utils.dart';
import 'package:chess_rps/presentation/widget/skeleton_loader.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class CapturedPiecesWidget extends ConsumerWidget {
  final Board board;
  final bool isLightSide;

  const CapturedPiecesWidget({
    required this.board,
    required this.isLightSide,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the board's lost figures lists to ensure widget rebuilds when captures occur
    final lostLightFigures = ref.watch(
      gameControllerProvider.select((state) => state.board.lostLightFigures),
    );
    final lostDarkFigures = ref.watch(
      gameControllerProvider.select((state) => state.board.lostDarkFigures),
    );
    
    final capturedFigures = isLightSide
        ? lostDarkFigures
        : lostLightFigures;

    // Get piece set from settings
    final settingsAsync = ref.watch(settingsControllerProvider);
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
          return _buildPieceIcon(figure, pieceSet);
        }).toList(),
      ),
    );
  }

  Widget _buildPieceIcon(Figure figure, String pieceSet) {
    // Use same approach as cell_widget
    final side = figure.side.toString(); // Returns 'black' or 'white'
    final role = figure.role.toString().split('.').last.toLowerCase();
    final safePieceSet = pieceSet.isNotEmpty ? pieceSet : 'cardinal';
    final imageUrl = AssetUrl.getChessPieceUrl(safePieceSet, side, role);

    return SizedBox(
      width: 24,
      height: 24,
      child: Image.network(
        imageUrl,
        fit: BoxFit.contain,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Skeleton(
            width: 24,
            height: 24,
            borderRadius: 2,
          );
        },
      ),
    );
  }
}

