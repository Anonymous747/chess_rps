import 'package:chess_rps/common/enum.dart';
import 'package:chess_rps/common/palette.dart';
import 'package:chess_rps/presentation/mediator/game_mode_mediator.dart';
import 'package:chess_rps/presentation/mediator/player_side_mediator.dart';
import 'package:chess_rps/presentation/utils/avatar_utils.dart';
import 'package:chess_rps/presentation/widget/user_avatar_widget.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class TimerWidget extends ConsumerWidget {
  final int lightPlayerTimeSeconds;
  final int darkPlayerTimeSeconds;
  final Side currentTurn;
  final VoidCallback? onFinishGame;

  const TimerWidget({
    Key? key,
    required this.lightPlayerTimeSeconds,
    required this.darkPlayerTimeSeconds,
    required this.currentTurn,
    this.onFinishGame,
  }) : super(key: key);

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPlayerLight = PlayerSideMediator.playerSide.isLight;
    final playerTime = isPlayerLight ? lightPlayerTimeSeconds : darkPlayerTimeSeconds;
    final opponentTime = isPlayerLight ? darkPlayerTimeSeconds : lightPlayerTimeSeconds;
    final isPlayerTurn = (isPlayerLight && currentTurn == Side.light) ||
        (!isPlayerLight && currentTurn == Side.dark);

    // Get opponent avatar icon name
    final opponentAvatarIconName = _getOpponentAvatarIconName();

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // Opponent timer
        _buildTimer(
          context: context,
          ref: ref,
          label: 'Opponent',
          time: opponentTime,
          isActive: !isPlayerTurn,
          avatarIconName: opponentAvatarIconName,
          isCurrentUser: false,
        ),
        // Finish game button (between timers)
        if (onFinishGame != null) ...[
          const SizedBox(width: 12),
          _buildFinishGameButton(context),
          const SizedBox(width: 12),
        ],
        // Player timer
        _buildTimer(
          context: context,
          ref: ref,
          label: 'You',
          time: playerTime,
          isActive: isPlayerTurn,
          avatarIconName: null, // Will use current user's equipped avatar
          isCurrentUser: true,
        ),
      ],
    );
  }

  /// Get opponent avatar icon name
  /// For AI, returns a consistent avatar (avatar_2 for AI)
  /// For real opponent, returns null (will use default)
  String? _getOpponentAvatarIconName() {
    if (GameModesMediator.opponentMode.isAI) {
      // Use a consistent avatar for AI (avatar_2 - "Cool Dude")
      return AvatarUtils.getAvatarIconName(2);
    }
    // For real opponents, we could fetch their avatar from backend
    // For now, use a default one (avatar_3)
    return AvatarUtils.getAvatarIconName(3);
  }

  Widget _buildTimer({
    required BuildContext context,
    required WidgetRef ref,
    required String label,
    required int time,
    required bool isActive,
    String? avatarIconName,
    required bool isCurrentUser,
  }) {
    final isLowTime = time < 60; // Less than 1 minute
    final color = isLowTime
        ? Palette.error
        : isActive
            ? Palette.accent
            : Palette.textSecondary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: isActive
            ? Palette.backgroundElevated
            : Palette.backgroundTertiary,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isActive 
              ? Palette.accent.withOpacity(0.5) 
              : Palette.glassBorder,
          width: isActive ? 2 : 1,
        ),
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: Palette.accent.withOpacity(0.3),
                  blurRadius: 12,
                  spreadRadius: 0,
                ),
              ]
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Avatar icon
          if (isCurrentUser)
            UserAvatarWidget(
              size: 36,
            )
          else
            UserAvatarByIconWidget(
              avatarIconName: avatarIconName,
              size: 36,
            ),
          const SizedBox(width: 12),
          // Label and time
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Palette.textSecondary,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _formatTime(time),
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: color,
                  letterSpacing: 1.5,
                  fontFamily: 'monospace',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFinishGameButton(BuildContext context) {
    return GestureDetector(
      onTap: onFinishGame,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: Palette.backgroundTertiary,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Palette.error.withOpacity(0.5),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Palette.error.withOpacity(0.2),
              blurRadius: 8,
              spreadRadius: 0,
            ),
          ],
        ),
        child: Icon(
          Icons.flag,
          color: Palette.error,
          size: 24,
        ),
      ),
    );
  }
}


