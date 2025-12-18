import 'dart:math';
import 'package:chess_rps/common/enum.dart';
import 'package:chess_rps/common/logger.dart';
import 'package:chess_rps/common/rps_choice.dart';
import 'package:chess_rps/data/service/socket/socket_action_handler.dart';
import 'package:chess_rps/domain/model/cell.dart';
import 'package:chess_rps/domain/service/action_handler.dart';
import 'package:chess_rps/domain/service/game_strategy.dart';
import 'package:chess_rps/presentation/controller/game_controller.dart';
import 'package:chess_rps/presentation/mediator/game_mode_mediator.dart';
import 'package:chess_rps/presentation/mediator/player_side_mediator.dart';
import 'package:chess_rps/presentation/state/game_state.dart';

class RpsGameStrategy extends GameStrategy {
  final Random _random = Random();

  @override
  Future<void> initialAction(
      GameController controller, GameState state) async {
    AppLogger.info('RPS game strategy initial action', tag: 'RpsGameStrategy');
    // Show RPS overlay at the start if player is dark side
    if (!PlayerSideMediator.playerSide.isLight) {
      AppLogger.debug('Player is dark side, showing RPS overlay', tag: 'RpsGameStrategy');
      controller.showRpsOverlay();
    }
  }

  @override
  Future<void> onPressed(
      GameController controller, GameState state, Cell pressedCell) async {
    // In RPS mode, check if player needs to win RPS first
    if (state.showRpsOverlay) {
      // RPS overlay is showing, don't allow moves yet
      return;
    }

    // Check if player won the last RPS round
    if (state.playerWonRps == false) {
      // Player lost RPS, can't make move
      return;
    }

    await super.onPressed(controller, state, pressedCell);
  }

  @override
  Future<bool> makeMove(GameController controller, Cell pressedCell) async {
    // Check if player won RPS before allowing move
    final currentState = controller.currentState;
    if (currentState.playerWonRps != true) {
      return false;
    }

    final isMoved = await super.makeMove(controller, pressedCell);

    if (!isMoved) return false;

    // After move, show RPS overlay for next round
    controller.showRpsOverlay();

    return true;
  }

  /// Handle RPS choice selection
  Future<void> handleRpsChoice(
      GameController controller,
      GameState currentState,
      ActionHandler actionHandler,
      RpsChoice playerChoice) async {
    AppLogger.info('Handling RPS choice: ${playerChoice.name}', tag: 'RpsGameStrategy');
    controller.updateState(currentState.copyWith(
      playerRpsChoice: playerChoice,
      waitingForRpsResult: true,
    ));

    // Send RPS choice to backend if using socket
    if (GameModesMediator.opponentMode == OpponentMode.socket) {
      if (actionHandler is SocketActionHandler) {
        AppLogger.debug('Sending RPS choice to socket', tag: 'RpsGameStrategy');
        await actionHandler.sendRpsChoice(playerChoice);
      }
    }

    // Get opponent's choice
    RpsChoice opponentChoice;
    if (GameModesMediator.opponentMode == OpponentMode.ai) {
      // AI opponent - random choice
      opponentChoice = RpsChoice.values[_random.nextInt(3)];
      AppLogger.debug('AI opponent choice: ${opponentChoice.name}', tag: 'RpsGameStrategy');
    } else {
      // Socket opponent - wait for response from backend
      AppLogger.debug('Waiting for opponent RPS choice from socket', tag: 'RpsGameStrategy');
      opponentChoice = await _getOpponentRpsChoice(actionHandler);
      AppLogger.debug('Received opponent choice: ${opponentChoice.name}', tag: 'RpsGameStrategy');
    }

    // Determine winner
    final playerWon = playerChoice.beats(opponentChoice);
    final isTie = playerChoice == opponentChoice;

    AppLogger.info('RPS result - Player: ${playerChoice.name}, Opponent: ${opponentChoice.name}, Player won: $playerWon, Tie: $isTie', tag: 'RpsGameStrategy');

    final updatedState = controller.currentState.copyWith(
      opponentRpsChoice: opponentChoice,
      playerWonRps: isTie ? null : playerWon,
      waitingForRpsResult: false,
      showRpsOverlay: false,
    );
    controller.updateState(updatedState);

    // If player won or tie, they can make a move
    // If player lost, opponent makes a move
    if (!playerWon && !isTie) {
      // Player lost, opponent makes move
      AppLogger.info('Player lost RPS, opponent will make move', tag: 'RpsGameStrategy');
      await controller.makeOpponentsMove();
      // After opponent move, show RPS overlay again
      controller.showRpsOverlay();
    } else {
      AppLogger.info('Player won RPS or tie, player can make move', tag: 'RpsGameStrategy');
    }
  }

  Future<RpsChoice> _getOpponentRpsChoice(ActionHandler actionHandler) async {
    if (GameModesMediator.opponentMode == OpponentMode.socket) {
      // Wait for RPS result from WebSocket
      if (actionHandler is SocketActionHandler) {
        final message = await actionHandler.messageStream.firstWhere((message) {
          return message['type'] == 'rps_result';
        });
        
        final data = message['data'] as Map<String, dynamic>;
        final player1Choice = data['player1_choice'] as String?;
        final player2Choice = data['player2_choice'] as String?;
        
        // Determine which choice is the opponent's
        // This is simplified - in real implementation, you'd know your player ID
        final opponentChoiceStr = player2Choice ?? player1Choice;
        if (opponentChoiceStr != null) {
          return RpsChoice.values.firstWhere(
            (choice) => choice.name == opponentChoiceStr,
            orElse: () => RpsChoice.values[_random.nextInt(3)],
          );
        }
      }
    }
    
    // Fallback to random for AI
    return RpsChoice.values[_random.nextInt(3)];
  }
}
