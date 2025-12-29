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
import 'package:chess_rps/presentation/state/game_state.dart';

class RpsGameStrategy extends GameStrategy {
  final Random _random = Random();

  @override
  Future<void> initialAction(
      GameController controller, GameState state) async {
    AppLogger.info('RPS game strategy initial action', tag: 'RpsGameStrategy');
    // Show RPS overlay at the start for both players
    // The first move goes to the player whose turn it is
    AppLogger.debug('Showing initial RPS overlay', tag: 'RpsGameStrategy');
    controller.showRpsOverlay();
  }

  @override
  Future<void> onPressed(
      GameController controller, GameState state, Cell pressedCell) async {
    // In RPS mode, check if player needs to win RPS first
    if (state.showRpsOverlay) {
      // RPS overlay is showing, don't allow moves yet
      return;
    }

    // Check if player has remaining moves from RPS wins
    if (state.playerRpsMovesRemaining <= 0) {
      // No remaining moves, need to win RPS first
      return;
    }

    // In RPS mode, allow player to select and move their pieces regardless of currentOrder
    // The RPS winner should always be able to make moves
    final playerSide = state.playerSide;
    
    // Allow selection of player's own pieces regardless of currentOrder
    if (pressedCell.isOccupied &&
        pressedCell.figure!.side == playerSide) {
      AppLogger.info(
        'RPS mode: Player selecting own piece (bypassing turn check)',
        tag: 'RpsGameStrategy'
      );
      controller.showAvailableActions(pressedCell);
      controller.ref.notifyListeners();
      return;
    }

    // Allow moves if player has selected piece and target is valid
    if (state.selectedFigure != null &&
        (pressedCell.isAvailable || pressedCell.canBeKnockedDown)) {
      // Double-check: if target cell has player's own piece, don't move
      if (pressedCell.isOccupied &&
          pressedCell.figure!.side == playerSide) {
        AppLogger.warning(
          'RPS mode: BLOCKED MOVE - Target cell contains own piece!',
          tag: 'RpsGameStrategy'
        );
        return;
      }
      
      AppLogger.info(
        'RPS mode: Player making move (bypassing turn check)',
        tag: 'RpsGameStrategy'
      );
      await makeMove(controller, pressedCell);
    }
  }

  @override
  Future<bool> makeMove(GameController controller, Cell pressedCell) async {
    // Check if player has remaining moves from RPS wins
    final currentState = controller.currentState;
    if (currentState.playerRpsMovesRemaining <= 0) {
      return false;
    }

    final isMoved = await super.makeMove(controller, pressedCell);

    if (!isMoved) return false;

    // Decrement remaining moves
    final updatedState = currentState.copyWith(
      playerRpsMovesRemaining: currentState.playerRpsMovesRemaining - 1,
    );
    controller.updateState(updatedState);

    // After move, if no moves remaining, show RPS overlay for next round
    if (updatedState.playerRpsMovesRemaining <= 0) {
      controller.showRpsOverlay();
    }

    return true;
  }

  /// Handle RPS choice selection
  /// This method handles a single RPS round
  /// If there's a tie, it will show the overlay again and wait for a new choice
  Future<void> handleRpsChoice(
      GameController controller,
      GameState currentState,
      ActionHandler actionHandler,
      RpsChoice playerChoice) async {
    AppLogger.info('Handling RPS choice: ${playerChoice.name}', tag: 'RpsGameStrategy');
    
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
      // AI opponent - always random choice
      opponentChoice = RpsChoice.values[_random.nextInt(3)];
      AppLogger.debug('AI opponent choice: ${opponentChoice.name}', tag: 'RpsGameStrategy');
    } else {
      // Socket opponent - wait for response from backend
      AppLogger.debug('Waiting for opponent RPS choice from socket', tag: 'RpsGameStrategy');
      opponentChoice = await _getOpponentRpsChoice(actionHandler, 1, currentState.playerSide);
      AppLogger.debug('Received opponent choice: ${opponentChoice.name}', tag: 'RpsGameStrategy');
    }

    // Determine winner
    final playerWon = playerChoice.beats(opponentChoice);
    final isTie = playerChoice == opponentChoice;

    AppLogger.info('RPS round - Player: ${playerChoice.name}, Opponent: ${opponentChoice.name}, Player won: $playerWon, Tie: $isTie', tag: 'RpsGameStrategy');

    // If tie, show overlay again and wait for new choice (don't process result yet)
    if (isTie) {
      AppLogger.info('RPS tie! Showing overlay for new selection...', tag: 'RpsGameStrategy');
      // Clear previous choices and show overlay again for both players to select new items
      // The overlay key includes isRpsTie, so changing it will force a reset
      controller.updateState(controller.currentState.copyWith(
        playerRpsChoice: null, // Clear previous choice so overlay resets
        opponentRpsChoice: null, // Clear opponent choice
        waitingForRpsResult: false, // Not waiting - players need to select again
        showRpsOverlay: true, // Show overlay again for new selection
        isRpsTie: true, // Mark as tie so overlay shows tie message
      ));
      // Exit early - wait for player to select a new choice
      // When they select, handleRpsChoice will be called again with the new choice
      return;
    }

    // Calculate moves to grant based on consecutive wins
    // For now, each RPS win grants 1 move, but we track consecutive wins
    final currentMovesRemaining = currentState.playerRpsMovesRemaining;
    final movesToAdd = playerWon == true ? 1 : 0;

    // In RPS mode, don't change currentOrder based on RPS result
    // currentOrder should follow normal chess turn order (white, black, white, black...)
    // The RPS winner can make moves regardless of currentOrder
    // Timer should resume for the RPS winner
    final playerSide = currentState.playerSide;
    final winnerSide = playerWon == true 
        ? playerSide 
        : playerWon == false 
            ? playerSide.opposite 
            : currentState.currentOrder; // Fallback if somehow null
    
    // In RPS mode, update currentOrder to the winner's side for timer tracking
    // The winner's timer should run, regardless of normal chess turn order
    // After a move is made, currentOrder will be updated to follow normal chess turn order
    // Hide the overlay when winner is determined
    final updatedState = controller.currentState.copyWith(
      opponentRpsChoice: opponentChoice,
      playerRpsChoice: playerChoice,
      playerWonRps: playerWon,
      playerRpsMovesRemaining: currentMovesRemaining + movesToAdd,
      waitingForRpsResult: false,
      showRpsOverlay: false, // Hide overlay when winner is determined
      isRpsTie: false, // Clear tie flag when winner is determined
      currentOrder: winnerSide, // Set to winner's side for timer tracking
      currentTurnStartedAt: DateTime.now(), // Reset turn start time for timer resume
    );
    controller.updateState(updatedState);

    // Restart timer countdown - it will track the RPS winner's side
    controller.restartTimerCountdown();

    AppLogger.info('RPS final result - Player won: $playerWon, Moves remaining: ${updatedState.playerRpsMovesRemaining}, Timer resumed for: ${winnerSide.name}', tag: 'RpsGameStrategy');

    // If player lost, opponent makes move
    if (playerWon == false) {
      // Player lost, opponent makes move
      AppLogger.info('Player lost RPS, opponent will make move', tag: 'RpsGameStrategy');
      
      // In online mode, don't call makeOpponentsMove() - wait for opponent's move via WebSocket
      // In AI mode, trigger the AI to make a move
      if (GameModesMediator.opponentMode == OpponentMode.ai) {
        await controller.makeOpponentsMove();
      } else {
        AppLogger.info('Online mode: Waiting for opponent move via WebSocket', tag: 'RpsGameStrategy');
        // Don't call makeOpponentsMove() - the opponent will send their move via WebSocket
        // The WebSocket listener will process it when received
      }
      
      // After opponent move, show RPS overlay again
      // For online mode, this will happen after we receive the opponent's move
      // For AI mode, this happens after makeOpponentsMove() completes
      if (GameModesMediator.opponentMode == OpponentMode.ai) {
        controller.showRpsOverlay();
      }
    } else {
      AppLogger.info('Player won RPS, can make ${updatedState.playerRpsMovesRemaining} move(s)', tag: 'RpsGameStrategy');
    }
  }

  Future<RpsChoice> _getOpponentRpsChoice(ActionHandler actionHandler, int roundNumber, Side playerSide) async {
    if (GameModesMediator.opponentMode == OpponentMode.socket) {
      // Wait for RPS result from WebSocket
      if (actionHandler is SocketActionHandler) {
        AppLogger.debug('Waiting for RPS result message from WebSocket (round $roundNumber)', tag: 'RpsGameStrategy');
        
        // Filter messages to get rps_result for the current or later round
        // This prevents consuming messages from earlier rounds if they arrive out of order
        // We accept the first rps_result message that matches our round or later
        int attempts = 0;
        const maxAttempts = 10; // Safety limit
        
        while (attempts < maxAttempts) {
          attempts++;
          final message = await actionHandler.messageStream.firstWhere((message) {
            final type = message['type'] as String?;
            if (type != 'rps_result') return false;
            
            // Check if this message is for the current round or later
            final data = message['data'] as Map<String, dynamic>?;
            if (data != null) {
              final roundNumberFromBackend = data['round_number'] as int?;
              if (roundNumberFromBackend != null) {
                // Accept if it's for the current round or later
                // This handles cases where messages arrive out of order
                return roundNumberFromBackend >= roundNumber;
              }
            }
            return false;
          });
          
          AppLogger.debug('Received RPS result message (attempt $attempts): $message', tag: 'RpsGameStrategy');
          final data = message['data'] as Map<String, dynamic>?;
          if (data != null) {
            final roundNumberFromBackend = data['round_number'] as int?;
            AppLogger.debug('RPS result round: $roundNumberFromBackend, waiting for: $roundNumber', tag: 'RpsGameStrategy');
            
            // Extract opponent choice from this message
            final player1Choice = data['player1_choice'] as String?;
            final player2Choice = data['player2_choice'] as String?;
            
            AppLogger.debug('RPS result data - Round: $roundNumberFromBackend, Player1: $player1Choice, Player2: $player2Choice', tag: 'RpsGameStrategy');
            AppLogger.debug('Our player side: ${playerSide.name}', tag: 'RpsGameStrategy');
            
            // Determine which player we are based on player side
            final isPlayer1 = playerSide.isLight;
            
            // Extract opponent's choice: if we're player1, opponent is player2, and vice versa
            final opponentChoiceStr = isPlayer1 ? player2Choice : player1Choice;
            
            if (opponentChoiceStr != null) {
              AppLogger.debug('Extracted opponent choice: $opponentChoiceStr (we are ${isPlayer1 ? "player1" : "player2"})', tag: 'RpsGameStrategy');
              return RpsChoice.values.firstWhere(
                (choice) => choice.name.toLowerCase() == opponentChoiceStr.toLowerCase(),
                orElse: () {
                  AppLogger.warning('Invalid opponent choice: $opponentChoiceStr, using random', tag: 'RpsGameStrategy');
                  return RpsChoice.values[_random.nextInt(3)];
                },
              );
            } else {
              AppLogger.warning('RPS result message missing choice data, retrying...', tag: 'RpsGameStrategy');
              // Continue to next attempt
            }
          } else {
            AppLogger.warning('RPS result message missing data field, retrying...', tag: 'RpsGameStrategy');
            // Continue to next attempt
          }
        }
        
        AppLogger.warning('Failed to get opponent RPS choice after $attempts attempts, using random', tag: 'RpsGameStrategy');
      }
    }
    
    // Fallback to random (should not happen in socket mode, but safe fallback)
    return RpsChoice.values[_random.nextInt(3)];
  }
}
