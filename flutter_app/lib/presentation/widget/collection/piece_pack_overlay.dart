import 'package:chess_rps/common/palette.dart';
import 'package:chess_rps/presentation/utils/piece_pack_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chess_rps/presentation/controller/settings_controller.dart';
import 'package:chess_rps/common/logger.dart';

class PiecePackOverlay extends ConsumerWidget {
  final String packName;

  const PiecePackOverlay({
    Key? key,
    required this.packName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(settingsControllerProvider);
    final isSelected = settingsAsync.valueOrNull?.pieceSet == packName;
    final whitePieces = PiecePackUtils.getAllPieceImages(packName, isWhite: true);
    final blackPieces = PiecePackUtils.getAllPieceImages(packName, isWhite: false);
    
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(20),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        decoration: BoxDecoration(
          color: Palette.backgroundTertiary,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Palette.glassBorder),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      PiecePackUtils.formatPackName(packName),
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Palette.textPrimary,
                      ),
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isSelected)
                        Container(
                          margin: const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Palette.success.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Palette.success),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.check_circle, color: Palette.success, size: 16),
                              const SizedBox(width: 4),
                              Text(
                                'Selected',
                                style: TextStyle(
                                  color: Palette.success,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isSelected)
                        Container(
                          margin: const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Palette.success.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Palette.success),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.check_circle, color: Palette.success, size: 16),
                              const SizedBox(width: 4),
                              Text(
                                'Selected',
                                style: TextStyle(
                                  color: Palette.success,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: Icon(Icons.close, color: Palette.textSecondary),
                        style: IconButton.styleFrom(
                          backgroundColor: Palette.backgroundSecondary,
                          shape: const CircleBorder(),
                        ),
                      ),
                    ],
                  ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Content
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // White pieces section
                    Text(
                      'White Pieces',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Palette.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildPiecesGrid(whitePieces),
                    
                    const SizedBox(height: 24),
                    
                    // Black pieces section
                    Text(
                      'Black Pieces',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Palette.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildPiecesGrid(blackPieces),
                    
                    const SizedBox(height: 24),
                    
                    // Select button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          AppLogger.info('Selecting piece set from overlay: $packName', tag: 'PiecePackOverlay');
                          try {
                            await ref.read(settingsControllerProvider.notifier).updatePieceSet(packName);
                            if (context.mounted) {
                              Navigator.of(context).pop();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('${PiecePackUtils.formatPackName(packName)} selected'),
                                  backgroundColor: Palette.success,
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                            }
                          } catch (e) {
                            AppLogger.error('Error selecting piece set', tag: 'PiecePackOverlay', error: e);
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Failed to select piece set: $e'),
                                  backgroundColor: Palette.error,
                                ),
                              );
                            }
                          }
                        },
                        icon: Icon(
                          isSelected ? Icons.check_circle : Icons.check,
                          color: Palette.textPrimary,
                        ),
                        label: Text(
                          isSelected ? 'Currently Selected' : 'Select This Set',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Palette.textPrimary,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isSelected
                              ? Palette.success
                              : Palette.purpleAccent,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPiecesGrid(Map<String, String> pieces) {
    final pieceOrder = ['king', 'queen', 'rook', 'bishop', 'knight', 'pawn'];
    
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1,
      ),
      itemCount: pieceOrder.length,
      itemBuilder: (context, index) {
        final pieceName = pieceOrder[index];
        final imagePath = pieces[pieceName]!;
        
        return Container(
          decoration: BoxDecoration(
            color: Palette.backgroundSecondary,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Palette.glassBorder),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Image.asset(
                    imagePath,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(
                        Icons.broken_image,
                        color: Palette.textTertiary,
                        size: 32,
                      );
                    },
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  _formatPieceName(pieceName),
                  style: TextStyle(
                    fontSize: 10,
                    color: Palette.textSecondary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _formatPieceName(String pieceName) {
    return pieceName[0].toUpperCase() + pieceName.substring(1);
  }
}

