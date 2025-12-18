import 'package:chess_rps/common/palette.dart';
import 'package:flutter/material.dart';

class PieceSetSelectionDialog extends StatelessWidget {
  final String currentPieceSet;
  final Function(String) onPieceSetSelected;

  const PieceSetSelectionDialog({
    Key? key,
    required this.currentPieceSet,
    required this.onPieceSetSelected,
  }) : super(key: key);

  static const List<String> availablePieceSets = [
    'neon_3d',
    'classic',
    'modern',
    'medieval',
    'minimal',
    'retro',
  ];

  String _formatPieceSetName(String pieceSet) {
    return pieceSet.split('_').map((word) {
      if (word.isEmpty) return '';
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Palette.backgroundTertiary,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(color: Palette.glassBorder),
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        constraints: const BoxConstraints(maxWidth: 400),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select Piece Set',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Palette.textPrimary,
              ),
            ),
            const SizedBox(height: 24),
            ...availablePieceSets.map((pieceSet) {
              final isSelected = pieceSet == currentPieceSet;
              return InkWell(
                onTap: () {
                  onPieceSetSelected(pieceSet);
                  Navigator.of(context).pop();
                },
                child: Container(
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Palette.purpleAccent.withValues(alpha: 0.2)
                        : Palette.backgroundSecondary,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? Palette.purpleAccent
                          : Palette.glassBorder,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          _formatPieceSetName(pieceSet),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: Palette.textPrimary,
                          ),
                        ),
                      ),
                      if (isSelected)
                        Icon(
                          Icons.check_circle,
                          color: Palette.purpleAccent,
                          size: 24,
                        ),
                    ],
                  ),
                ),
              );
            }),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  'Cancel',
                  style: TextStyle(color: Palette.textSecondary),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

