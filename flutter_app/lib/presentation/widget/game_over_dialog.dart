import 'package:chess_rps/common/enum.dart';
import 'package:chess_rps/common/palette.dart';
import 'package:flutter/material.dart';

/// Beautiful dialog shown when game ends (checkmate or stalemate)
class GameOverDialog extends StatelessWidget {
  final Side? winner;
  final Side playerSide;
  final bool isCheckmate;
  final bool isStalemate;
  final VoidCallback onReturnToMenu;

  const GameOverDialog({
    Key? key,
    required this.winner,
    required this.playerSide,
    required this.isCheckmate,
    required this.isStalemate,
    required this.onReturnToMenu,
  }) : super(key: key);

  bool get playerWon => winner == playerSide;
  bool get isDraw => isStalemate || winner == null;

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
              // Icon and Title
              _buildIconAndTitle(),
              const SizedBox(height: 24),
              // Result Message
              _buildResultMessage(),
              const SizedBox(height: 32),
              // Return to Menu Button
              _buildReturnButton(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIconAndTitle() {
    if (isDraw) {
      return Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Palette.warning.withValues(alpha: 0.2),
              shape: BoxShape.circle,
              border: Border.all(
                color: Palette.warning.withValues(alpha: 0.5),
                width: 2,
              ),
            ),
            child: Icon(
              Icons.handshake,
              size: 48,
              color: Palette.warning,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Draw!',
            style: TextStyle(
              color: Palette.textPrimary,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      );
    } else if (playerWon) {
      return Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Palette.success.withValues(alpha: 0.2),
              shape: BoxShape.circle,
              border: Border.all(
                color: Palette.success.withValues(alpha: 0.5),
                width: 2,
              ),
            ),
            child: Icon(
              Icons.emoji_events,
              size: 48,
              color: Palette.gold,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Victory!',
            style: TextStyle(
              color: Palette.success,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      );
    } else {
      return Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Palette.error.withValues(alpha: 0.2),
              shape: BoxShape.circle,
              border: Border.all(
                color: Palette.error.withValues(alpha: 0.5),
                width: 2,
              ),
            ),
            child: Icon(
              Icons.sentiment_dissatisfied,
              size: 48,
              color: Palette.error,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Defeat',
            style: TextStyle(
              color: Palette.error,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      );
    }
  }

  Widget _buildResultMessage() {
    String message;
    Color messageColor;

    if (isDraw) {
      message = isStalemate
          ? 'The game ended in a stalemate.\nNeither player wins.'
          : 'The game ended in a draw.';
      messageColor = Palette.warning;
    } else if (playerWon) {
      message = isCheckmate
          ? 'Congratulations! You won by checkmate!'
          : 'Congratulations! You won!';
      messageColor = Palette.success;
    } else {
      message = isCheckmate
          ? 'You were checkmated.\nBetter luck next time!'
          : 'You lost the game.\nBetter luck next time!';
      messageColor = Palette.error;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: messageColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: messageColor.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: messageColor,
          fontSize: 16,
          fontWeight: FontWeight.w600,
          height: 1.5,
        ),
      ),
    );
  }

  Widget _buildReturnButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          Navigator.of(context).pop();
          onReturnToMenu();
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Palette.accent,
          foregroundColor: Palette.textPrimary,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 4,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.home,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              'Return to Menu',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
