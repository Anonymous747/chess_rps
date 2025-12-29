import 'package:chess_rps/common/palette.dart';
import 'package:chess_rps/common/rps_choice.dart';
import 'package:flutter/material.dart';

/// Widget to display RPS choices and winner at the top of the chess screen
class RpsResultDisplay extends StatelessWidget {
  final RpsChoice? playerChoice;
  final RpsChoice? opponentChoice;
  final bool? playerWon; // true = player won, false = opponent won, null = tie

  const RpsResultDisplay({
    Key? key,
    this.playerChoice,
    this.opponentChoice,
    this.playerWon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Don't show if no choices have been made yet
    if (playerChoice == null && opponentChoice == null) {
      return const SizedBox.shrink();
    }

    final isTie = playerWon == null && playerChoice != null && opponentChoice != null;
    final playerWonRps = playerWon == true;
    final opponentWonRps = playerWon == false;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Palette.backgroundTertiary,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isTie
              ? Palette.warning.withValues(alpha: 0.5)
              : playerWonRps
                  ? Palette.success.withValues(alpha: 0.5)
                  : Palette.error.withValues(alpha: 0.5),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: (isTie
                    ? Palette.warning
                    : playerWonRps
                        ? Palette.success
                        : Palette.error)
                .withValues(alpha: 0.2),
            blurRadius: 8,
            spreadRadius: 0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Player choice
          _buildChoiceDisplay(
            choice: playerChoice,
            label: 'You',
            isWinner: playerWonRps,
            isTie: isTie,
          ),
          // VS indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              isTie ? 'TIE' : 'VS',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: isTie
                    ? Palette.warning
                    : Palette.textSecondary,
              ),
            ),
          ),
          // Opponent choice
          _buildChoiceDisplay(
            choice: opponentChoice,
            label: 'Opponent',
            isWinner: opponentWonRps,
            isTie: isTie,
          ),
        ],
      ),
    );
  }

  Widget _buildChoiceDisplay({
    required RpsChoice? choice,
    required String label,
    required bool isWinner,
    required bool isTie,
  }) {
    if (choice == null) {
      return Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Palette.backgroundElevated,
              shape: BoxShape.circle,
              border: Border.all(
                color: Palette.glassBorder,
                width: 1,
              ),
            ),
            child: const Center(
              child: Icon(
                Icons.question_mark,
                color: Palette.textSecondary,
                size: 24,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Palette.textSecondary,
            ),
          ),
        ],
      );
    }

    final icon = _getIconForChoice(choice);
    final color = isTie
        ? Palette.warning
        : isWinner
            ? Palette.success
            : Palette.textSecondary;

    return Column(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: isWinner
                ? Palette.success.withValues(alpha: 0.2)
                : isTie
                    ? Palette.warning.withValues(alpha: 0.2)
                    : Palette.backgroundElevated,
            shape: BoxShape.circle,
            border: Border.all(
              color: color,
              width: isWinner || isTie ? 3 : 1,
            ),
            boxShadow: isWinner
                ? [
                    BoxShadow(
                      color: Palette.success.withValues(alpha: 0.4),
                      blurRadius: 12,
                      spreadRadius: 2,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : isTie
                    ? [
                        BoxShadow(
                          color: Palette.warning.withValues(alpha: 0.3),
                          blurRadius: 8,
                          spreadRadius: 1,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
          ),
          child: Icon(
            icon,
            color: color,
            size: 32,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: color,
                fontWeight: isWinner ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            if (isWinner) ...[
              const SizedBox(width: 4),
              Icon(
                Icons.emoji_events,
                size: 14,
                color: Palette.success,
              ),
            ],
          ],
        ),
        Text(
          choice.displayName,
          style: TextStyle(
            fontSize: 10,
            color: color,
            fontWeight: isWinner ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  IconData _getIconForChoice(RpsChoice choice) {
    switch (choice) {
      case RpsChoice.rock:
        return Icons.circle_outlined;
      case RpsChoice.paper:
        return Icons.description_outlined;
      case RpsChoice.scissors:
        return Icons.content_cut_outlined;
    }
  }
}

