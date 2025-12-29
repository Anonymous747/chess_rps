import 'dart:async';
import 'dart:math';
import 'package:chess_rps/common/palette.dart';
import 'package:chess_rps/common/rps_choice.dart';
import 'package:flutter/material.dart';

class RpsOverlay extends StatefulWidget {
  final Function(RpsChoice) onChoiceSelected;
  final bool isWaitingForOpponent;
  final String? opponentChoice;
  final bool isTie; // Indicates if the current round is a tie

  const RpsOverlay({
    Key? key,
    required this.onChoiceSelected,
    this.isWaitingForOpponent = false,
    this.opponentChoice,
    this.isTie = false,
  }) : super(key: key);

  @override
  State<RpsOverlay> createState() => _RpsOverlayState();
}

class _RpsOverlayState extends State<RpsOverlay> {
  RpsChoice? _selectedChoice;
  Timer? _timer;
  int _timeRemaining = 5; // 5 seconds to select
  final Random _random = Random();
  bool _hasSelected = false;

  @override
  void initState() {
    super.initState();
    // Reset selection state when overlay is shown (including tie replays)
    _selectedChoice = null;
    _hasSelected = false;
    _startTimer();
  }
  
  @override
  void didUpdateWidget(RpsOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    // If tie flag changed from false to true, reset selection state for replay
    // This allows players to select a new choice after a tie
    if (!oldWidget.isTie && widget.isTie) {
      _selectedChoice = null;
      _hasSelected = false;
      _startTimer(); // Restart timer for tie replay
    }
    // If tie flag changed from true to false, also reset (new round started)
    if (oldWidget.isTie && !widget.isTie) {
      _selectedChoice = null;
      _hasSelected = false;
      _startTimer(); // Restart timer for new round
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    _timeRemaining = 5;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _timeRemaining--;
        });
        if (_timeRemaining <= 0 && !_hasSelected) {
          _timer?.cancel();
          // Auto-select random choice
          final randomChoice = RpsChoice.values[_random.nextInt(3)];
          _selectChoice(randomChoice, isAutoSelected: true);
        }
      }
    });
  }

  void _selectChoice(RpsChoice choice, {bool isAutoSelected = false}) {
    if (_hasSelected) return; // Prevent multiple selections
    
    setState(() {
      _selectedChoice = choice;
      _hasSelected = true;
    });
    _timer?.cancel();
    // Call the callback which will hide the overlay
    widget.onChoiceSelected(choice);
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Palette.black50.withValues(alpha: 0.7),
      child: Center(
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutBack,
          builder: (context, value, child) {
            // Clamp values to ensure they're within valid range
            final clampedValue = value.clamp(0.0, 1.0);
            return Transform.scale(
              scale: clampedValue,
              child: Opacity(
                opacity: clampedValue,
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
                        color: Palette.black50.withValues(alpha: value * 0.5),
                        blurRadius: 30 * value,
                        spreadRadius: 0,
                        offset: Offset(0, 15 * value),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Palette.accent.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Palette.accent.withValues(alpha: 0.3),
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
                      if (widget.isTie)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          margin: const EdgeInsets.only(bottom: 8),
                          decoration: BoxDecoration(
                            color: Palette.warning.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Palette.warning,
                              width: 1.5,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.refresh,
                                size: 18,
                                color: Palette.warning,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Tie! Choose again',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Palette.warning,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        )
                      else
                        Text(
                          'Choose your move before making a chess move',
                          style: TextStyle(
                            fontSize: 14,
                            color: Palette.textSecondary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      const SizedBox(height: 16),
                      // Timer countdown
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: _timeRemaining <= 2 
                              ? Palette.error.withValues(alpha: 0.2)
                              : Palette.warning.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: _timeRemaining <= 2
                                ? Palette.error
                                : Palette.warning,
                            width: 2,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.timer_outlined,
                              size: 20,
                              color: _timeRemaining <= 2
                                  ? Palette.error
                                  : Palette.warning,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '$_timeRemaining',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: _timeRemaining <= 2
                                    ? Palette.error
                                    : Palette.warning,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'seconds',
                              style: TextStyle(
                                fontSize: 14,
                                color: _timeRemaining <= 2
                                    ? Palette.error
                                    : Palette.warning,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (_hasSelected && _selectedChoice != null) ...[
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: Palette.success.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Palette.success,
                              width: 1,
                            ),
                          ),
                          child: Text(
                            'Selected: ${_selectedChoice!.displayName}',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Palette.success,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 16),
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
                              color: Palette.info.withValues(alpha: 0.3),
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
          },
        ),
      ),
    );
  }

  Widget _buildChoiceButton(RpsChoice choice, IconData icon) {
    final isSelected = _selectedChoice == choice;
    // Disable selection only if waiting for opponent (not during tie - tie allows new selection)
    final isDisabled = widget.isWaitingForOpponent;
    return GestureDetector(
      onTap: isDisabled ? null : () => _selectChoice(choice),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 90,
        height: 90,
        decoration: BoxDecoration(
          color: isDisabled
              ? Palette.backgroundTertiary
              : (isSelected
                  ? Palette.accent.withValues(alpha: 0.2)
                  : Palette.backgroundElevated),
          border: Border.all(
            color: isDisabled
                ? Palette.glassBorder.withValues(alpha: 0.5)
                : (isSelected
                    ? Palette.accent
                    : Palette.glassBorder),
            width: isSelected ? 2.5 : 1.5,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: isSelected && !isDisabled
              ? [
                  BoxShadow(
                    color: Palette.accent.withValues(alpha: 0.4),
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
              color: isDisabled
                  ? Palette.textTertiary
                  : (isSelected ? Palette.accent : Palette.textSecondary),
            ),
            const SizedBox(height: 6),
            Text(
              choice.displayName,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isDisabled
                    ? Palette.textTertiary
                    : (isSelected ? Palette.accent : Palette.textSecondary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
