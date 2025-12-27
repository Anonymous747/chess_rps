import 'package:chess_rps/common/logger.dart';
import 'package:chess_rps/presentation/screen/mode_selector.dart';
import 'package:chess_rps/presentation/screen/opponent_selector.dart';
import 'package:chess_rps/presentation/screen/ai_difficulty_selector.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// State for the play flow navigation
enum PlayFlowState {
  modeSelector,
  opponentSelector,
  difficultySelector,
}

/// Provider to manage play flow state
final playFlowStateProvider = StateNotifierProvider<PlayFlowStateNotifier, PlayFlowState>((ref) {
  return PlayFlowStateNotifier();
});

class PlayFlowStateNotifier extends StateNotifier<PlayFlowState> {
  PlayFlowStateNotifier() : super(PlayFlowState.modeSelector);

  void goToOpponentSelector() {
    AppLogger.info('Play flow: Moving to opponent selector', tag: 'PlayFlowState');
    state = PlayFlowState.opponentSelector;
  }

  void goToDifficultySelector() {
    AppLogger.info('Play flow: Moving to difficulty selector', tag: 'PlayFlowState');
    state = PlayFlowState.difficultySelector;
  }

  void goBackToModeSelector() {
    AppLogger.info('Play flow: Moving back to mode selector', tag: 'PlayFlowState');
    state = PlayFlowState.modeSelector;
  }

  void goBackToOpponentSelector() {
    AppLogger.info('Play flow: Moving back to opponent selector', tag: 'PlayFlowState');
    state = PlayFlowState.opponentSelector;
  }

  void reset() {
    AppLogger.info('Play flow: Resetting to mode selector', tag: 'PlayFlowState');
    state = PlayFlowState.modeSelector;
  }
}

/// Unified play flow screen that handles mode, opponent, and difficulty selection
/// with smooth animated transitions between states
class PlayFlowScreen extends ConsumerWidget {
  const PlayFlowScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playFlowState = ref.watch(playFlowStateProvider);

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      transitionBuilder: (Widget child, Animation<double> animation) {
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.1, 0.0),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
            )),
            child: child,
          ),
        );
      },
      child: _getScreenForState(playFlowState, ref, key: ValueKey(playFlowState)),
    );
  }

  Widget _getScreenForState(PlayFlowState state, WidgetRef ref, {required Key key}) {
    switch (state) {
      case PlayFlowState.modeSelector:
        return ModeSelectorContent(key: key);
      case PlayFlowState.opponentSelector:
        return OpponentSelectorContent(key: key);
      case PlayFlowState.difficultySelector:
        return AIDifficultySelectorContent(key: key);
    }
  }
}

