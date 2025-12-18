import 'dart:async';

import 'package:chess_rps/common/enum.dart';
import 'package:chess_rps/common/extension.dart';
import 'package:chess_rps/common/logger.dart';
import 'package:chess_rps/common/rps_choice.dart';
import 'package:chess_rps/data/service/game/rps_game_strategy.dart';
import 'package:chess_rps/data/service/socket/socket_action_handler.dart';
import 'package:chess_rps/domain/model/board.dart';
import 'package:chess_rps/domain/model/cell.dart';
import 'package:chess_rps/domain/model/position.dart';
import 'package:chess_rps/domain/service/action_handler.dart';
import 'package:chess_rps/domain/service/game_strategy.dart';
import 'package:chess_rps/domain/service/logger.dart';
import 'package:chess_rps/presentation/state/game_state.dart';
import 'package:chess_rps/presentation/utils/action_checker.dart';
import 'package:chess_rps/presentation/mediator/game_mode_mediator.dart';
import 'package:chess_rps/presentation/mediator/player_side_mediator.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'game_controller.g.dart';

@riverpod
class GameController extends _$GameController {
  @protected
  @visibleForTesting
  late final ActionHandler actionHandler;

  @protected
  @visibleForTesting
  late final Logger actionLogger;

  @protected
  @visibleForTesting
  late final GameStrategy gameStrategy;

  Timer? _timerCountdown;
  StreamSubscription<Map<String, dynamic>>? _websocketSubscription;

  @override
  GameState build() {
    AppLogger.info('Initializing GameController', tag: 'GameController');
    actionHandler = ref.read(actionHandlerProvider);
    AppLogger.info(
      'ActionHandler type: ${actionHandler.runtimeType}, Opponent mode: ${GameModesMediator.opponentMode}',
      tag: 'GameController'
    );
    actionLogger = ref.read(loggerProvider);
    gameStrategy = ref.read(gameStrategyProvider);

    final playerSide = PlayerSideMediator.playerSide;
    AppLogger.info('Player side: ${playerSide.name}', tag: 'GameController');

    final board = Board()..startGame();
    AppLogger.debug('Board initialized', tag: 'GameController');
    
    final initialState = GameState(
      board: board,
      playerSide: playerSide,
      lightPlayerTimeSeconds: 600,
      darkPlayerTimeSeconds: 600,
    );

    // Listen to WebSocket messages for timer updates (if using socket)
    if (actionHandler is SocketActionHandler) {
      AppLogger.info('Setting up WebSocket timer listener', tag: 'GameController');
      Future.microtask(() {
        _setupWebSocketTimerListener(actionHandler as SocketActionHandler);
      });
    }

    // Start timer countdown after state is initialized
    Future.microtask(() {
      AppLogger.debug('Starting timer countdown', tag: 'GameController');
      _startTimerCountdown();
    });

    // Call initial action after state is set
    Future.microtask(() async {
      AppLogger.debug('Executing initial game strategy action', tag: 'GameController');
      await gameStrategy.initialAction(this, state);
    });

    AppLogger.info('GameController initialized successfully', tag: 'GameController');
    return initialState;
  }

  void _setupWebSocketTimerListener(SocketActionHandler handler) {
    _websocketSubscription = handler.messageStream.listen((message) {
      final type = message['type'] as String?;
      if (type == 'timer_update' || type == 'move' || type == 'room_joined') {
        final data = message['data'] as Map<String, dynamic>?;
        if (data != null) {
          final lightTime = data['light_player_time'] as int?;
          final darkTime = data['dark_player_time'] as int?;
          final turnStartedAtStr = data['current_turn_started_at'] as String?;
          
          if (lightTime != null && darkTime != null) {
            state = state.copyWith(
              lightPlayerTimeSeconds: lightTime,
              darkPlayerTimeSeconds: darkTime,
              currentTurnStartedAt: turnStartedAtStr != null
                  ? DateTime.parse(turnStartedAtStr)
                  : DateTime.now(),
            );
            _restartTimerCountdown();
          }
        }
      }
    });
  }

  void _startTimerCountdown() {
    AppLogger.debug('Starting timer countdown', tag: 'GameController');
    _timerCountdown?.cancel();
    
    // Get current state safely
    final currentState = state;
    if (currentState.currentTurnStartedAt == null) {
      state = currentState.copyWith(currentTurnStartedAt: DateTime.now());
      AppLogger.debug('Initialized turn start time', tag: 'GameController');
    }

    _timerCountdown = Timer.periodic(const Duration(seconds: 1), (timer) {
      final currentState = state;
      if (currentState.currentTurnStartedAt == null) return;

      // Simply decrement by 1 second since timer fires every second
      final currentTime = currentState.currentOrder == Side.light
          ? currentState.lightPlayerTimeSeconds
          : currentState.darkPlayerTimeSeconds;

      final remaining = currentTime - 1;

      if (remaining <= 0) {
        timer.cancel();
        // Timeout - handle game end
        AppLogger.warning('Time out for ${currentState.currentOrder}', tag: 'GameController');
        // Set to 0 to avoid negative values
        if (currentState.currentOrder == Side.light) {
          state = currentState.copyWith(lightPlayerTimeSeconds: 0);
        } else {
          state = currentState.copyWith(darkPlayerTimeSeconds: 0);
        }
        return;
      }

      // Update timer (only log every 10 seconds to avoid spam)
      if (remaining % 10 == 0 || remaining < 60) {
        AppLogger.debug('Timer update - ${currentState.currentOrder.name}: ${remaining}s remaining', tag: 'GameController');
      }

      // Update timer
      if (currentState.currentOrder == Side.light) {
        state = currentState.copyWith(lightPlayerTimeSeconds: remaining);
      } else {
        state = currentState.copyWith(darkPlayerTimeSeconds: remaining);
      }
    });
  }

  void _restartTimerCountdown() {
    _startTimerCountdown();
  }

  Future<void> onPressed(Cell pressedCell) async {
    AppLogger.debug('Cell pressed: ${pressedCell.position.algebraicPosition}', tag: 'GameController');
    await gameStrategy.onPressed(this, state, pressedCell);
  }

  void _displayAvailableCells(Cell fromCell) {
    final movingSide = fromCell.figure?.side;
    if (movingSide == null) return;
    
    final isInCheck = ActionChecker.isKingInCheck(state.board, movingSide);
    
    if (isInCheck) {
      AppLogger.info(
        'King is in check for ${movingSide.name}. Filtering moves to only show moves that remove check.',
        tag: 'GameController'
      );
    }
    
    final availableHashes =
        ActionChecker.getAvailablePositionsHash(state.board, fromCell);

    AppLogger.debug(
      'Found ${availableHashes.length} available moves for ${fromCell.figure?.role} at ${fromCell.position.algebraicPosition}',
      tag: 'GameController'
    );

    for (final hash in availableHashes) {
      final position = hash.toPosition();
      final target = state.board.getCellAt(position.row, position.col);

      final canBeKnockedDown = fromCell.calculateCanBeKnockedDown(target);

      // Opposite figure available to knock
      if (canBeKnockedDown) {
        state.board.updateCell(position.row, position.col,
            (cell) => cell.copyWith(canBeKnockedDown: true));
      } else {
        state.board.updateCell(position.row, position.col,
            (cell) => cell.copyWith(isAvailable: true));
      }
    }
  }

  /// Display all available figure's actions on the board
  ///
  void showAvailableActions(Cell fromCell) {
    // Wipe selected cells before follow action
    if (state.selectedFigure != null) {
      state = state.copyWith(selectedFigure: null);
      state.board.removeSelection();
    }

    if (!fromCell.isSelected) {
      _displayAvailableCells(fromCell);
    }

    state.board.updateCell(fromCell.row, fromCell.col,
        (cell) => cell.copyWith(isSelected: !fromCell.isSelected));
    state = state.copyWith(
        selectedFigure: !fromCell.isSelected ? fromCell.positionHash : null);
  }

  /// Return the result is Opponents move has a correct status
  ///
  Future<bool> makeOpponentsMove() async {
    AppLogger.info('=== GameController.makeOpponentsMove() START ===', tag: 'GameController');
    AppLogger.info('Current game state:', tag: 'GameController');
    AppLogger.info('  - Current order (whose turn): ${state.currentOrder}', tag: 'GameController');
    AppLogger.info('  - Player side: ${state.playerSide}', tag: 'GameController');
    AppLogger.info('  - Opponent side: ${state.currentOrder}', tag: 'GameController');
    
    try {
      // Ensure board state is synced before getting opponent move
      AppLogger.info('Step 1: Visualizing board to sync state', tag: 'GameController');
      await actionHandler.visualizeBoard();
      AppLogger.info('Board visualization completed', tag: 'GameController');
      
      AppLogger.info('Step 2: Requesting opponent move from action handler', tag: 'GameController');
      final bestAction = await actionHandler.getOpponentsMove();
      AppLogger.info('Action handler returned: ${bestAction ?? "null"}', tag: 'GameController');

      if (bestAction.isNullOrEmpty) {
        AppLogger.warning('=== makeOpponentsMove() FAILED: No valid move found from opponent ===', tag: 'GameController');
        AppLogger.warning('Possible reasons:', tag: 'GameController');
        AppLogger.warning('  1. Stockfish returned null/empty', tag: 'GameController');
        AppLogger.warning('  2. No legal moves available', tag: 'GameController');
        AppLogger.warning('  3. Stockfish engine error', tag: 'GameController');
        return false;
      }

      AppLogger.info('Step 3: Parsing opponent move: $bestAction', tag: 'GameController');
      final fromPosition = bestAction!.substring(0, 2).convertToPosition();
      final targetPosition = bestAction.substring(2, 4).convertToPosition();
      AppLogger.info('  - From position: row ${fromPosition.row}, col ${fromPosition.col}', tag: 'GameController');
      AppLogger.info('  - To position: row ${targetPosition.row}, col ${targetPosition.col}', tag: 'GameController');

      final fromCell = state.board.getCellAt(fromPosition.row, fromPosition.col);
      final targetCell =
          state.board.getCellAt(targetPosition.row, targetPosition.col);
      
      AppLogger.info('  - From cell: ${fromCell.position.row},${fromCell.position.col}', tag: 'GameController');
      AppLogger.info('  - To cell: ${targetCell.position.row},${targetCell.position.col}', tag: 'GameController');

      // Check if the move is valid before executing
      AppLogger.info('Step 4: Validating move', tag: 'GameController');
      if (fromCell.figure == null) {
        AppLogger.warning('=== makeOpponentsMove() FAILED: No figure at source position ===', tag: 'GameController');
        AppLogger.warning('  - Source position: ${fromCell.position.algebraicPosition}', tag: 'GameController');
        AppLogger.warning('  - Cell is empty', tag: 'GameController');
        return false;
      }

      AppLogger.info('  - Source cell has figure: ${fromCell.figure!.role} (${fromCell.figure!.side})', tag: 'GameController');

      // Check if it's the opponent's turn
      // currentOrder should match the figure's side for the opponent's move to be valid
      AppLogger.info('Step 5: Checking turn validity', tag: 'GameController');
      AppLogger.info('  - Figure side: ${fromCell.figure!.side}', tag: 'GameController');
      AppLogger.info('  - Current order: ${state.currentOrder}', tag: 'GameController');
      AppLogger.info('  - Match: ${fromCell.figure!.side == state.currentOrder}', tag: 'GameController');
      
      if (fromCell.figure!.side != state.currentOrder) {
        AppLogger.warning('=== makeOpponentsMove() FAILED: Not opponent\'s turn ===', tag: 'GameController');
        AppLogger.warning('  - Expected side: ${state.currentOrder}', tag: 'GameController');
        AppLogger.warning('  - Figure side: ${fromCell.figure!.side}', tag: 'GameController');
        AppLogger.warning('  - This suggests a board state mismatch or Stockfish returned wrong side move', tag: 'GameController');
        return false;
      }

      AppLogger.info('Step 6: Executing opponent move via action', tag: 'GameController');
      final success = await _makeMoveViaAction(bestAction, fromCell, targetCell);
      if (success) {
        AppLogger.info('=== GameController.makeOpponentsMove() SUCCESS ===', tag: 'GameController');
        AppLogger.info('Opponent move executed successfully: $bestAction', tag: 'GameController');
        // Move history is already updated in _makeMoveViaAction
      } else {
        AppLogger.warning('=== GameController.makeOpponentsMove() FAILED: Move execution failed ===', tag: 'GameController');
        AppLogger.warning('Move was valid but execution failed', tag: 'GameController');
      }
      return success;
    } catch (e, stackTrace) {
      AppLogger.error('=== GameController.makeOpponentsMove() ERROR ===', tag: 'GameController', error: e, stackTrace: stackTrace);
      AppLogger.error('Exception details: $e', tag: 'GameController');
      return false;
    }
  }

  /// Helps to define selected cell
  ///
  Cell _getSelectedCell(Board board, Cell target, {Cell? from}) {
    if (from == null) {
      final selectedPosition = state.selectedFigure!.toPosition();
      return board.getCellAt(selectedPosition.row, selectedPosition.col);
    }

    return from;
  }

  /// Return the result is Opponents move has a correct status
  ///
  Future<bool> makeMove(Cell target, {Cell? from}) async {
    final board = state.board;
    final selectedCell = _getSelectedCell(board, target, from: from);

    final isMoveAvailable = selectedCell.moveFigure(board, target);
    if (!isMoveAvailable) {
      AppLogger.debug('Move not available', tag: 'GameController');
      return false;
    }

    final action =
        '${selectedCell.position.algebraicPosition}${target.position.algebraicPosition}';
    AppLogger.info('Making move: $action', tag: 'GameController');

    final success = await _makeMoveViaAction(action, selectedCell, target);
    if (success) {
      AppLogger.info('Move executed successfully: $action', tag: 'GameController');
    } else {
      AppLogger.warning('Failed to execute move: $action', tag: 'GameController');
    }
    return success;
  }

  /// Get [action] and make move according to it
  ///
  Future<bool> _makeMoveViaAction(
      String action, Cell selectedCell, Cell targetCell) async {
    AppLogger.debug('Executing move via action: $action', tag: 'GameController');
    try {
      await actionHandler.makeMove(action);
      AppLogger.debug('Move sent to action handler', tag: 'GameController');
    } catch (e) {
      AppLogger.error('Error sending move to action handler: $e', tag: 'GameController', error: e);
      return false;
    }

    final updatedBoard = state.board
      ..makeMove(selectedCell, targetCell)
      ..removeSelection();

    // Determine new current order (opposite side)
    final newCurrentOrder = state.currentOrder.opposite;
    
    // Check if the new current order's king is in check
    final kingInCheck = ActionChecker.isKingInCheck(updatedBoard, newCurrentOrder)
        ? newCurrentOrder
        : null;
    
    // Also check if the side that just moved is still in check (shouldn't happen, but check anyway)
    final previousSideInCheck = ActionChecker.isKingInCheck(updatedBoard, state.currentOrder)
        ? state.currentOrder
        : null;
    
    // Use the new current order's check status
    final finalCheckStatus = kingInCheck ?? previousSideInCheck;

    state = state.copyWith(
      board: updatedBoard,
      selectedFigure: null,
      currentOrder: newCurrentOrder,
      currentTurnStartedAt: DateTime.now(),
      kingInCheck: finalCheckStatus,
    );
    
    AppLogger.debug('Turn switched to: ${newCurrentOrder.name}', tag: 'GameController');
    if (finalCheckStatus != null) {
      AppLogger.info('King in check detected for: ${finalCheckStatus.name}', tag: 'GameController');
    }
    
    // Restart timer for new turn
    _restartTimerCountdown();

    actionLogger.add(action);
    AppLogger.debug('Move logged: $action', tag: 'GameController');
    
    // Update move history in state
    final updatedMoveHistory = [...state.moveHistory, action];
    state = state.copyWith(
      moveHistory: updatedMoveHistory,
    );
    AppLogger.info('Move history updated. Total moves: ${updatedMoveHistory.length}. Latest: $action', tag: 'GameController');

    return true;
  }

  void dispose() {
    AppLogger.info('Disposing GameController', tag: 'GameController');
    _timerCountdown?.cancel();
    _websocketSubscription?.cancel();
    PlayerSideMediator.makeByDefault();
    actionHandler.dispose();
    AppLogger.debug('GameController disposed', tag: 'GameController');
  }

  Future<void> executeCommand() async {
    await actionHandler.visualizeBoard();
  }

  /// Show RPS overlay before making a move
  void showRpsOverlay() {
    state = state.copyWith(
      showRpsOverlay: true,
      playerRpsChoice: null,
      opponentRpsChoice: null,
      playerWonRps: null,
      waitingForRpsResult: false,
    );
  }

  /// Handle RPS choice selection
  Future<void> handleRpsChoice(RpsChoice choice) async {
    if (gameStrategy is RpsGameStrategy) {
      await (gameStrategy as RpsGameStrategy).handleRpsChoice(
        this, 
        state, 
        actionHandler,
        choice
      );
    }
  }

  /// Hide RPS overlay
  void hideRpsOverlay() {
    state = state.copyWith(showRpsOverlay: false);
  }

  /// Get current game state (for use by game strategies)
  GameState get currentState => state;

  /// Update game state (for use by game strategies)
  void updateState(GameState newState) {
    state = newState;
  }
}
