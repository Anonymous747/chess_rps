import 'package:chess_rps/common/palette.dart';
import 'package:chess_rps/common/rps_choice.dart';
import 'package:flutter/material.dart';

class RpsOverlay extends StatefulWidget {
  final Function(RpsChoice) onChoiceSelected;
  final bool isWaitingForOpponent;
  final String? opponentChoice;

  const RpsOverlay({
    Key? key,
    required this.onChoiceSelected,
    this.isWaitingForOpponent = false,
    this.opponentChoice,
  }) : super(key: key);

  @override
  State<RpsOverlay> createState() => _RpsOverlayState();
}

class _RpsOverlayState extends State<RpsOverlay> {
  RpsChoice? _selectedChoice;

  void _selectChoice(RpsChoice choice) {
    setState(() {
      _selectedChoice = choice;
    });
    widget.onChoiceSelected(choice);
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Palette.black50,
      child: Center(
        child: Container(
          margin: const EdgeInsets.all(24),
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Palette.backgroundTertiary,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: Palette.glassBorder,
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Palette.black50,
                blurRadius: 30,
                spreadRadius: 0,
                offset: const Offset(0, 15),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Palette.accent.withOpacity(0.1),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Palette.accent.withOpacity(0.3),
                    width: 2,
                  ),
                ),
                child: Icon(
                  Icons.handshake,
                  size: 32,
                  color: Palette.accent,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Rock Paper Scissors',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Palette.textPrimary,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Choose your move before making a chess move',
                style: TextStyle(
                  fontSize: 14,
                  color: Palette.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              if (widget.isWaitingForOpponent)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Palette.accent),
                  ),
                )
              else
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildChoiceButton(
                      RpsChoice.rock,
                      Icons.circle_outlined,
                    ),
                    _buildChoiceButton(
                      RpsChoice.paper,
                      Icons.description_outlined,
                    ),
                    _buildChoiceButton(
                      RpsChoice.scissors,
                      Icons.content_cut_outlined,
                    ),
                  ],
                ),
              if (widget.opponentChoice != null) ...[
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Palette.backgroundElevated,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Palette.info.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 16,
                        color: Palette.info,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Opponent chose: ${widget.opponentChoice}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Palette.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChoiceButton(RpsChoice choice, IconData icon) {
    final isSelected = _selectedChoice == choice;
    return GestureDetector(
      onTap: () => _selectChoice(choice),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 90,
        height: 90,
        decoration: BoxDecoration(
          color: isSelected
              ? Palette.accent.withOpacity(0.2)
              : Palette.backgroundElevated,
          border: Border.all(
            color: isSelected
                ? Palette.accent
                : Palette.glassBorder,
            width: isSelected ? 2.5 : 1.5,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Palette.accent.withOpacity(0.4),
                    blurRadius: 16,
                    spreadRadius: 0,
                    offset: const Offset(0, 6),
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 36,
              color: isSelected ? Palette.accent : Palette.textSecondary,
            ),
            const SizedBox(height: 6),
            Text(
              choice.displayName,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? Palette.accent : Palette.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

