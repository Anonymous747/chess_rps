import 'dart:math';
import 'package:chess_rps/common/enum.dart';
import 'package:chess_rps/common/palette.dart';
import 'package:flutter/material.dart';

/// Dialog for selecting player side when playing against AI
class PlayerSideSelectionDialog extends StatelessWidget {
  final Function(Side selectedSide) onSideSelected;

  const PlayerSideSelectionDialog({
    Key? key,
    required this.onSideSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Palette.backgroundTertiary,
              Palette.backgroundSecondary,
            ],
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: Palette.glassBorder,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.5),
              blurRadius: 20,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Title
              Text(
                'Choose Your Side',
                style: TextStyle(
                  color: Palette.textPrimary,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'White always moves first',
                style: TextStyle(
                  color: Palette.textSecondary,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 32),
              // White option
              _buildSideOption(
                context,
                side: Side.light,
                label: 'White',
                icon: Icons.circle_outlined,
                onTap: () {
                  Navigator.of(context).pop();
                  onSideSelected(Side.light);
                },
              ),
              const SizedBox(height: 12),
              // Black option
              _buildSideOption(
                context,
                side: Side.dark,
                label: 'Black',
                icon: Icons.circle,
                onTap: () {
                  Navigator.of(context).pop();
                  onSideSelected(Side.dark);
                },
              ),
              const SizedBox(height: 12),
              // Randomize option
              _buildSideOption(
                context,
                side: null, // null means randomize
                label: 'Randomize',
                icon: Icons.shuffle,
                onTap: () {
                  Navigator.of(context).pop();
                  final random = Random();
                  final randomSide = random.nextBool() ? Side.light : Side.dark;
                  onSideSelected(randomSide);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSideOption(
    BuildContext context, {
    required Side? side,
    required String label,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Palette.backgroundElevated,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Palette.glassBorder,
          width: 1.5,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: side == Side.light
                      ? Palette.textPrimary
                      : side == Side.dark
                          ? Palette.textSecondary
                          : Palette.purpleAccent,
                  size: 24,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      color: Palette.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (side != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: side == Side.light
                          ? Palette.textPrimary.withValues(alpha: 0.1)
                          : Palette.textSecondary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      side == Side.light ? 'Moves First' : 'AI Moves First',
                      style: TextStyle(
                        color: side == Side.light
                            ? Palette.textPrimary
                            : Palette.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


