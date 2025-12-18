import 'package:chess_rps/common/enum.dart';
import 'package:chess_rps/common/palette.dart';
import 'package:chess_rps/presentation/mediator/player_side_mediator.dart';
import 'package:flutter/material.dart';

class TimerWidget extends StatelessWidget {
  final int lightPlayerTimeSeconds;
  final int darkPlayerTimeSeconds;
  final Side currentTurn;

  const TimerWidget({
    Key? key,
    required this.lightPlayerTimeSeconds,
    required this.darkPlayerTimeSeconds,
    required this.currentTurn,
  }) : super(key: key);

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final isPlayerLight = PlayerSideMediator.playerSide.isLight;
    final playerTime = isPlayerLight ? lightPlayerTimeSeconds : darkPlayerTimeSeconds;
    final opponentTime = isPlayerLight ? darkPlayerTimeSeconds : lightPlayerTimeSeconds;
    final isPlayerTurn = (isPlayerLight && currentTurn == Side.light) ||
        (!isPlayerLight && currentTurn == Side.dark);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // Opponent timer (top)
        _buildTimer(
          label: 'Opponent',
          time: opponentTime,
          isActive: !isPlayerTurn,
        ),
        // Player timer (bottom)
        _buildTimer(
          label: 'You',
          time: playerTime,
          isActive: isPlayerTurn,
        ),
      ],
    );
  }

  Widget _buildTimer({
    required String label,
    required int time,
    required bool isActive,
  }) {
    final isLowTime = time < 60; // Less than 1 minute
    final color = isLowTime
        ? Palette.error
        : isActive
            ? Palette.accent
            : Palette.textSecondary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
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
          const SizedBox(height: 6),
          Text(
            _formatTime(time),
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: color,
              letterSpacing: 1.5,
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }
}


