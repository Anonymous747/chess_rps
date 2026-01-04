import 'package:chess_rps/common/enum.dart';
import 'package:chess_rps/common/palette.dart';
import 'package:chess_rps/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

/// Beautiful dialog shown when game ends (checkmate or stalemate)
class GameOverDialog extends StatelessWidget {
  final Side? winner;
  final Side playerSide;
  final bool isCheckmate;
  final bool isStalemate;
  final VoidCallback onReturnToMenu;
  final int? xpGained;
  final int? ratingChange;
  final bool isOnlineGame; // If false (AI game), don't show rating change

  const GameOverDialog({
    Key? key,
    required this.winner,
    required this.playerSide,
    required this.isCheckmate,
    required this.isStalemate,
    required this.onReturnToMenu,
    this.xpGained,
    this.ratingChange,
    this.isOnlineGame = true,
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
              _buildIconAndTitle(context),
              const SizedBox(height: 24),
              // Result Message
              _buildResultMessage(context),
              const SizedBox(height: 24),
              // XP and Rating Changes
              if (xpGained != null || (ratingChange != null && ratingChange != 0 && isOnlineGame))
                _buildRewardsSection(context),
              const SizedBox(height: 32),
              // Return to Menu Button
              _buildReturnButton(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIconAndTitle(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
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
            l10n.draw,
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
            l10n.victory,
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
            l10n.defeat,
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

  Widget _buildResultMessage(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    String message;
    Color messageColor;

    if (isDraw) {
      message = isStalemate
          ? l10n.stalemateMessage
          : l10n.drawMessage;
      messageColor = Palette.warning;
    } else if (playerWon) {
      message = isCheckmate
          ? l10n.checkmateWin
          : l10n.winMessage;
      messageColor = Palette.success;
    } else {
      message = isCheckmate
          ? l10n.checkmateLoss
          : l10n.lossMessage;
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

  Widget _buildRewardsSection(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Palette.backgroundElevated,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Palette.glassBorder,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          if (xpGained != null)
            _buildRewardRow(
              icon: Icons.star,
              label: l10n.experience,
              value: l10n.xpGained(xpGained!),
              color: Palette.accent,
            ),
          if (xpGained != null && ratingChange != null && ratingChange != 0 && isOnlineGame)
            const SizedBox(height: 12),
          if (ratingChange != null && ratingChange != 0 && isOnlineGame)
            _buildRewardRow(
              icon: Icons.trending_up,
              label: l10n.rating,
              value: ratingChange! >= 0 ? '+$ratingChange' : '$ratingChange',
              color: ratingChange! >= 0 ? Palette.success : Palette.error,
            ),
        ],
      ),
    );
  }

  Widget _buildRewardRow({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Palette.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
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
              AppLocalizations.of(context)!.returnToMenu,
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
