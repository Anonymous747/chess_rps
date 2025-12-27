import 'dart:async';

import 'package:chess_rps/common/enum.dart';
import 'package:chess_rps/common/extension.dart';
import 'package:chess_rps/common/logger.dart';
import 'package:chess_rps/common/piece_notation.dart';
import 'package:chess_rps/common/rps_choice.dart';
import 'package:chess_rps/data/service/game/ai_action_handler.dart';
import 'package:chess_rps/data/service/game/rps_game_strategy.dart';
import 'package:chess_rps/data/service/socket/socket_action_handler.dart';
import 'package:chess_rps/domain/model/board.dart';
import 'package:chess_rps/domain/model/cell.dart';
import 'package:chess_rps/domain/model/position.dart';
import 'package:chess_rps/domain/service/action_handler.dart';
import 'package:chess_rps/domain/service/game_strategy.dart';
import 'package:chess_rps/domain/service/logger.dart';
import 'package:chess_rps/presentation/controller/settings_controller.dart';
import 'package:chess_rps/presentation/state/game_state.dart';
import 'package:chess_rps/presentation/utils/action_checker.dart';
import 'package:chess_rps/presentation/utils/effect_event.dart';
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
  String? _lastSentMoveNotation; // Track last move we sent to prevent processing our own echo
  
  // Effect event stream
  final _effectEventController = StreamController<EffectEvent>.broadcast();
  Stream<EffectEvent> get effectEvents => _effectEventController.stream;

  @override
  GameState build() {
    AppLogger.info('Initializing GameController', tag: 'GameController');
    // Use watch instead of read to keep the provider alive during the game
    actionHandler = ref.watch(actionHandlerProvider);
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

    // Connect to WebSocket and set up listener for online games
    // Check both the actionHandler type AND the opponent mode to ensure we're in online mode
    if (GameModesMediator.opponentMode == OpponentMode.socket) {
      if (actionHandler is SocketActionHandler) {
        AppLogger.info('Setting up WebSocket connection for online game', tag: 'GameController');
        final socketHandler = actionHandler as SocketActionHandler;
        
        // Get room code from mediator and connect
        Future.microtask(() async {
          try {
            final roomCode = GameModesMediator.currentRoomCode;
            if (roomCode != null && roomCode.isNotEmpty) {
              AppLogger.info('Connecting SocketActionHandler to room: $roomCode', tag: 'GameController');
              await socketHandler.connectToRoom(roomCode);
              
              // Setup listener after connection is established
              _setupWebSocketTimerListener(socketHandler);
            } else {
              AppLogger.error('Room code not available! Cannot connect to WebSocket.', tag: 'GameController');
            }
          } catch (e) {
            AppLogger.error('Error setting up WebSocket connection: $e', tag: 'GameController', error: e);
          }
        });
      } else {
        AppLogger.error(
          'CRITICAL: Opponent mode is socket but ActionHandler is ${actionHandler.runtimeType}, not SocketActionHandler! '
          'This indicates a provider caching issue. Attempting to use shared room handler.',
          tag: 'GameController'
        );
        // Try to use the shared room handler directly
        final sharedHandler = GameModesMediator.sharedRoomHandler;
        if (sharedHandler != null) {
          AppLogger.info('Using shared room handler to setup WebSocket listener', tag: 'GameController');
          final socketHandler = SocketActionHandler(); // Create a new one that will reuse the shared handler
          Future.microtask(() async {
            try {
              final roomCode = GameModesMediator.currentRoomCode;
              if (roomCode != null && roomCode.isNotEmpty) {
                await socketHandler.connectToRoom(roomCode);
                _setupWebSocketTimerListener(socketHandler);
              }
            } catch (e) {
              AppLogger.error('Error setting up WebSocket connection with shared handler: $e', tag: 'GameController', error: e);
            }
          });
        } else {
          AppLogger.error('No shared room handler available! Cannot setup WebSocket listener.', tag: 'GameController');
        }
      }
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
      AppLogger.info('Game fully initialized and ready', tag: 'GameController');
    });

    AppLogger.info('GameController initialized successfully', tag: 'GameController');
    return initialState;
  }

  void _setupWebSocketTimerListener(SocketActionHandler handler) {
    // Double-check we're in online mode before setting up listener
    if (GameModesMediator.opponentMode != OpponentMode.socket) {
      AppLogger.warning('Attempted to setup WebSocket listener but not in online mode - skipping', tag: 'GameController');
      return;
    }
    
    AppLogger.info('Setting up WebSocket listener for online game', tag: 'GameController');
    _websocketSubscription = handler.messageStream.listen(
      (message) async {
        try {
            final type = message['type'] as String?;
          if (type == 'timer_update' || type == 'move' || type == 'room_joined' || type == 'player_left' || type == 'error' || type == 'surrender' || type == 'disconnected') {
            // Handle surrender - opponent surrendered, player wins
            // Only process in online mode
            if (type == 'surrender') {
              if (GameModesMediator.opponentMode == OpponentMode.socket) {
                AppLogger.info('Received surrender message - opponent surrendered, player wins!', tag: 'GameController');
                AppLogger.info('Current game state before surrender: gameOver=${state.gameOver}, winner=${state.winner?.name}', tag: 'GameController');
                // End game with player winning
                final opponentSide = state.playerSide.opposite;
                _endGameWithSurrender(opponentSide);
                AppLogger.info('Game state after surrender: gameOver=${state.gameOver}, winner=${state.winner?.name}', tag: 'GameController');
              } else {
                AppLogger.warning('Received surrender message but not in online mode - ignoring', tag: 'GameController');
              }
              return;
            }
            
            // Handle player_left - opponent disconnected, player wins
            // Only process in online mode
            if (type == 'player_left') {
              if (GameModesMediator.opponentMode == OpponentMode.socket) {
                AppLogger.info('Received player_left message - opponent disconnected, player wins!', tag: 'GameController');
                AppLogger.info('Current game state before player_left: gameOver=${state.gameOver}, winner=${state.winner?.name}', tag: 'GameController');
                // Only end game if it's not already over
                if (!state.gameOver) {
                  // End game with player winning
                  final opponentSide = state.playerSide.opposite;
                  _endGameWithSurrender(opponentSide);
                  AppLogger.info('Game state after player_left: gameOver=${state.gameOver}, winner=${state.winner?.name}', tag: 'GameController');
                } else {
                  AppLogger.info('Game already over, ignoring player_left message', tag: 'GameController');
                }
              } else {
                AppLogger.warning('Received player_left message but not in online mode - ignoring', tag: 'GameController');
              }
              return;
            }
            
            // Handle disconnected - WebSocket connection lost, opponent wins
            if (type == 'disconnected') {
              AppLogger.info('Received disconnected message - connection lost, opponent wins!', tag: 'GameController');
              // Only end game if we're in online mode and game is not already over
              if (GameModesMediator.opponentMode == OpponentMode.socket && !state.gameOver) {
                // End game with opponent winning (we lost connection)
                final playerSide = state.playerSide;
                _endGameWithSurrender(playerSide);
              } else {
                AppLogger.info('Ignoring disconnected message - not in online mode or game already over', tag: 'GameController');
              }
              return;
            }
            
            // Handle error messages
            if (type == 'error') {
              final errorData = message['data'] as Map<String, dynamic>?;
              final errorMsg = errorData?['message'] as String? ?? 'Unknown error';
              AppLogger.warning('Received error from WebSocket: $errorMsg', tag: 'GameController');
              // Don't close connection or interrupt game for server errors
              return;
            }
            
            // Handle room_joined - update player side if provided
            // player_side is at the top level of the message, not in 'data'
            if (type == 'room_joined') {
              final playerSideStr = message['player_side'] as String?;
              if (playerSideStr != null) {
                // Convert backend side ("light"/"dark") to Flutter Side enum
                final playerSide = playerSideStr == 'light' ? Side.light : Side.dark;
                PlayerSideMediator.changePlayerSide(playerSide);
                AppLogger.info('Player side updated to: ${playerSide.name} (from server)', tag: 'GameController');
                
                // Update game state with correct player side
                state = state.copyWith(playerSide: playerSide);
              } else {
                AppLogger.warning('No player_side in room_joined message', tag: 'GameController');
              }
            }
            
            final data = message['data'] as Map<String, dynamic>?;
            if (data != null) {
              // Handle opponent move
              if (type == 'move') {
                final moveNotation = data['move_notation'] as String?;
                // Accept both formats: "e2e4" (4 chars, old format) or "Pe2e4" (5 chars, with piece type)
                if (moveNotation != null && (moveNotation.length == 4 || moveNotation.length == 5)) {
                  AppLogger.info('Received opponent move via WebSocket: $moveNotation', tag: 'GameController');
                  // Process move in a separate try-catch to prevent stream errors
                  try {
                    AppLogger.debug('About to process opponent move: $moveNotation', tag: 'GameController');
                    await _processOpponentMove(moveNotation);
                    AppLogger.debug('Successfully processed opponent move: $moveNotation', tag: 'GameController');
                  } catch (e, stackTrace) {
                    AppLogger.error('=== CRITICAL: Error processing opponent move: $e ===', tag: 'GameController', error: e, stackTrace: stackTrace);
                    AppLogger.error('Move notation was: $moveNotation', tag: 'GameController');
                    AppLogger.error('Error type: ${e.runtimeType}', tag: 'GameController');
                    // Don't rethrow - continue listening for messages
                    // Connection should remain open even if move processing fails
                  }
                }
              }
              
              // Update timer (works for both 'move' and 'timer_update' messages)
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
        } catch (e, stackTrace) {
          // Catch any errors in message processing to prevent stream from closing
          AppLogger.error('Error processing WebSocket message: $e', tag: 'GameController', error: e, stackTrace: stackTrace);
          // Don't rethrow - continue listening for messages
        }
      },
      onError: (error) {
        // Handle stream errors without closing connection
        AppLogger.error('WebSocket stream error: $error', tag: 'GameController', error: error);
        // Don't close connection - stream errors shouldn't interrupt the game
      },
      onDone: () {
        AppLogger.warning('WebSocket stream closed (onDone)', tag: 'GameController');
        // When stream closes, end the game - opponent disconnected
        // Only end game if it's not already over and we're in online mode
        if (!state.gameOver && GameModesMediator.opponentMode == OpponentMode.socket) {
          AppLogger.info('WebSocket connection closed - ending game, opponent wins', tag: 'GameController');
          final playerSide = state.playerSide;
          _endGameWithSurrender(playerSide);
        } else if (GameModesMediator.opponentMode != OpponentMode.socket) {
          AppLogger.info('WebSocket onDone called but not in online mode - ignoring', tag: 'GameController');
        }
      },
      cancelOnError: false, // Don't cancel subscription on error
    );
  }

  /// Process a move received from the opponent via WebSocket
  /// This applies the move to the board and checks for game end conditions
  Future<void> _processOpponentMove(String moveNotation) async {
    AppLogger.info('=== _processOpponentMove START ===', tag: 'GameController');
      AppLogger.info('Processing opponent move: $moveNotation', tag: 'GameController');
      
      // Parse move notation (format: "Pe2e4" -> piece P, from "e2", to "e4")
      // Also support old format without piece: "e2e4"
      final parsedMove = PieceNotation.parseMoveNotation(moveNotation);
      final fromStr = parsedMove['from'] as String? ?? '';
      final toStr = parsedMove['to'] as String? ?? '';
      Role? pieceRoleFromNotation = parsedMove['piece'] as Role?;
      
      if (fromStr.isEmpty || toStr.isEmpty) {
        AppLogger.warning('Invalid move notation format: $moveNotation', tag: 'GameController');
        return;
      }
      
      AppLogger.info('  - From: $fromStr, To: $toStr${pieceRoleFromNotation != null ? ", Piece: ${pieceRoleFromNotation.name}" : ""}', tag: 'GameController');
      
      // Convert algebraic notation to Position
      // For online games, moves are in absolute notation (from white's perspective)
      // For AI games, moves are in relative notation (from player's perspective)
      final fromPosition = GameModesMediator.opponentMode == OpponentMode.socket
          ? fromStr.convertFromAbsoluteNotation()
          : fromStr.convertToPosition();
      final targetPosition = GameModesMediator.opponentMode == OpponentMode.socket
          ? toStr.convertFromAbsoluteNotation()
          : toStr.convertToPosition();
      
      AppLogger.info('  - From position: row ${fromPosition.row}, col ${fromPosition.col}', tag: 'GameController');
      AppLogger.info('  - To position: row ${targetPosition.row}, col ${targetPosition.col}', tag: 'GameController');
      
      // CRITICAL: Check for echo BEFORE accessing the cell, because our own move may have already moved the piece
      // First check: Is this the move we just sent? (most reliable for online games)
      // Compare both full notation and positions (in case format differs: "Pe2e4" vs "e2e4")
      final isEcho = _lastSentMoveNotation == moveNotation ||
          (_lastSentMoveNotation != null && 
           _lastSentMoveNotation!.length >= 4 && 
           moveNotation.length >= 4 &&
           (_lastSentMoveNotation!.substring(_lastSentMoveNotation!.length - 4) == 
            moveNotation.substring(moveNotation.length - 4)));
      
      if (isEcho) {
        AppLogger.info('=== _processOpponentMove: Skipping - this is our own move (echo) ===', tag: 'GameController');
        AppLogger.info('  - Move notation matches our last sent move: $_lastSentMoveNotation', tag: 'GameController');
        AppLogger.info('  - Clearing stored move notation', tag: 'GameController');
        _lastSentMoveNotation = null; // Clear it so we don't block legitimate moves
        return;
      }
      
      // Second check: If currentOrder matches our side, it's likely our move
      if (state.currentOrder == state.playerSide) {
        AppLogger.info('=== _processOpponentMove: Skipping - it\'s our turn (our move echoed) ===', tag: 'GameController');
        AppLogger.info('  - Current order is ${state.playerSide} (our side), so this is our move', tag: 'GameController');
        return;
      }
      
      final fromCell = state.board.getCellAt(fromPosition.row, fromPosition.col);
      final targetCell = state.board.getCellAt(targetPosition.row, targetPosition.col);
      
      // Determine opponent side (opposite of player side)
      final opponentSide = state.playerSide.opposite;
      
      AppLogger.info('=== _processOpponentMove VALIDATION ===', tag: 'GameController');
      AppLogger.info('  - Move notation: $moveNotation', tag: 'GameController');
      AppLogger.info('  - Player side: ${state.playerSide}', tag: 'GameController');
      AppLogger.info('  - Opponent side: $opponentSide', tag: 'GameController');
      AppLogger.info('  - Current order (whose turn): ${state.currentOrder}', tag: 'GameController');
      AppLogger.info('  - From position: row ${fromPosition.row}, col ${fromPosition.col}', tag: 'GameController');
      
      // Validate move - check if piece exists at source
      // If no piece, it could be:
      // 1. Our own move being echoed (already handled above, but check again if echo check was missed)
      // 2. Board state mismatch
      if (fromCell.figure == null) {
        AppLogger.warning('=== _processOpponentMove FAILED: No figure at source position ===', tag: 'GameController');
        AppLogger.warning('  - This might be our own move being processed twice, or board state mismatch', tag: 'GameController');
        AppLogger.warning('  - Move notation: $moveNotation', tag: 'GameController');
        AppLogger.warning('  - From position: row ${fromPosition.row}, col ${fromPosition.col} (${fromStr})', tag: 'GameController');
        AppLogger.warning('  - Current order: ${state.currentOrder}, Player side: ${state.playerSide}', tag: 'GameController');
        
        // If it's our turn now, this is definitely our own echo - skip it
        // Also check if this matches our last sent move (double-check, comparing positions)
        final isEchoCheck = _lastSentMoveNotation != null && 
            _lastSentMoveNotation!.length >= 4 && 
            moveNotation.length >= 4 &&
            (_lastSentMoveNotation!.substring(_lastSentMoveNotation!.length - 4) == 
             moveNotation.substring(moveNotation.length - 4));
        if (state.currentOrder == state.playerSide || _lastSentMoveNotation == moveNotation || isEchoCheck) {
          AppLogger.info('  - Confirmed: This is our own move echo, skipping', tag: 'GameController');
          AppLogger.info('  - currentOrder check: ${state.currentOrder == state.playerSide}', tag: 'GameController');
          AppLogger.info('  - lastSentMove check: ${_lastSentMoveNotation == moveNotation || isEchoCheck}', tag: 'GameController');
          _lastSentMoveNotation = null; // Clear it
          return;
        }
        
        // Otherwise, this is a real error - can't process a move without a piece
        AppLogger.error('  - ERROR: Cannot process opponent move - no piece at source and not our echo', tag: 'GameController');
        return;
      }
      
      AppLogger.info('  - Figure side at source (${fromStr}): ${fromCell.figure!.side}', tag: 'GameController');
      
      // It's opponent's turn, so this must be opponent's move - process it
      // Even if the piece side doesn't match perfectly due to board initialization, trust the server
      AppLogger.info('=== _processOpponentMove: Processing - it\'s opponent\'s turn ===', tag: 'GameController');
      AppLogger.info('  - Current order is ${state.currentOrder} (opponent\'s side), processing move', tag: 'GameController');
      
      // If piece side is wrong due to board initialization, fix it before processing
      // This can happen when board is initialized relative to player perspective
      if (fromCell.figure!.side != opponentSide) {
        AppLogger.warning('=== _processOpponentMove: Piece side mismatch - fixing ===', tag: 'GameController');
        AppLogger.warning('  - Expected opponent side: $opponentSide', tag: 'GameController');
        AppLogger.warning('  - Actual figure side: ${fromCell.figure!.side}', tag: 'GameController');
        AppLogger.warning('  - This is a board initialization issue - fixing piece side', tag: 'GameController');
        
        // Replace the figure with the correct side
        // This ensures the move is processed correctly
        final originalFigure = fromCell.figure!;
        AppLogger.warning('  - Replacing ${originalFigure.side} ${originalFigure.role} with ${opponentSide} ${originalFigure.role}', tag: 'GameController');
        
        // Create a new figure with the correct side and same role
        final correctedFigure = originalFigure.copyWith(side: opponentSide);
        
        // Update the cell with the corrected figure
        state.board.updateCell(fromPosition.row, fromPosition.col, (cell) {
          return cell.copyWith(figure: correctedFigure);
        });
        
        AppLogger.info('  - Fixed: Cell now has opponent piece', tag: 'GameController');
      }
      
      // Get fresh cell references after potential fix
      final currentFromCell = state.board.getCellAt(fromPosition.row, fromPosition.col);
      final currentTargetCell = state.board.getCellAt(targetPosition.row, targetPosition.col);
      
      try {
        // Get auto-queen setting
        AppLogger.debug('Step 1: Getting auto-queen setting', tag: 'GameController');
        final settingsAsync = ref.read(settingsControllerProvider);
        final autoQueen = settingsAsync.valueOrNull?.autoQueen ?? true;
        AppLogger.debug('Auto-queen setting: $autoQueen', tag: 'GameController');
        
        // Handle capture
        AppLogger.debug('Step 2: Checking for captures', tag: 'GameController');
        final capturedFigure = currentTargetCell.isOccupied ? currentTargetCell.figure : null;
        if (capturedFigure != null) {
          AppLogger.info('Piece captured: ${capturedFigure.role} (${capturedFigure.side})', tag: 'GameController');
          state.board.pushKnockedFigure(capturedFigure);
          AppLogger.debug('Captured piece added to knocked figures', tag: 'GameController');
        }
        
        // Apply move to board
        AppLogger.debug('Step 3: Applying move to board', tag: 'GameController');
        final updatedBoard = state.board;
        try {
          updatedBoard.makeMove(currentFromCell, currentTargetCell, autoQueen: autoQueen);
          updatedBoard.removeSelection();
          AppLogger.debug('Move applied successfully to board', tag: 'GameController');
        } catch (e, stackTrace) {
          AppLogger.error('CRITICAL: Error applying move to board: $e', tag: 'GameController', error: e, stackTrace: stackTrace);
          AppLogger.error('From cell: row ${fromCell.row}, col ${fromCell.col}, figure: ${fromCell.figure?.role} (${fromCell.figure?.side})', tag: 'GameController');
          AppLogger.error('To cell: row ${targetCell.row}, col ${targetCell.col}, figure: ${targetCell.figure?.role} (${targetCell.figure?.side})', tag: 'GameController');
          throw e; // Re-throw to be caught by outer try-catch
        }
        
        // Determine new current order (opposite side - now player's turn)
        AppLogger.debug('Step 4: Determining new turn order', tag: 'GameController');
        final newCurrentOrder = state.currentOrder.opposite;
        AppLogger.debug('New current order: $newCurrentOrder', tag: 'GameController');
        
        // Check if the new current order's king is in check
        AppLogger.debug('Step 5: Checking for check/checkmate/stalemate', tag: 'GameController');
        Side? kingInCheck;
        try {
          if (ActionChecker.isKingInCheck(updatedBoard, newCurrentOrder)) {
            kingInCheck = newCurrentOrder;
            AppLogger.info('King in check detected for: ${kingInCheck.name}', tag: 'GameController');
          }
        } catch (e, stackTrace) {
          AppLogger.error('Error checking for king in check: $e', tag: 'GameController', error: e, stackTrace: stackTrace);
          kingInCheck = null; // Continue even if check detection fails
        }
        
        // Update state
        AppLogger.debug('Step 6: Updating game state', tag: 'GameController');
        state = state.copyWith(
          board: updatedBoard,
          selectedFigure: null,
          currentOrder: newCurrentOrder,
          currentTurnStartedAt: DateTime.now(),
          kingInCheck: kingInCheck,
        );
        AppLogger.debug('State updated successfully', tag: 'GameController');
        
        AppLogger.info('Turn switched to: ${newCurrentOrder.name}', tag: 'GameController');
        
        // Check for checkmate or stalemate after the move
        AppLogger.debug('Step 7: Checking for end game conditions', tag: 'GameController');
        try {
          if (ActionChecker.isCheckmate(updatedBoard, newCurrentOrder)) {
            AppLogger.warning(
              'CHECKMATE detected after opponent move! ${newCurrentOrder.name} is checkmated.',
              tag: 'GameController'
            );
            _endGameWithCheckmate(newCurrentOrder);
            return;
          } else if (ActionChecker.isStalemate(updatedBoard, newCurrentOrder)) {
            AppLogger.warning(
              'STALEMATE detected after opponent move! ${newCurrentOrder.name} is stalemated.',
              tag: 'GameController'
            );
            _endGameWithStalemate(newCurrentOrder);
            return;
          }
        } catch (e, stackTrace) {
          AppLogger.error('Error checking for checkmate/stalemate: $e', tag: 'GameController', error: e, stackTrace: stackTrace);
          // Continue - don't throw, game can continue even if end game check fails
        }
        
        // Update move history - IMPORTANT: Add opponent's move to history
        // Ensure move notation includes piece type if it wasn't already there
        AppLogger.debug('Step 8: Updating move history', tag: 'GameController');
        String moveWithPiece = moveNotation;
        
        // If move notation doesn't include piece type, add it based on the moved piece
        if (moveNotation.length == 4) {
          // Old format without piece - need to add piece type
          // The piece was at currentFromCell before move, but it's already moved
          // So we get it from the pieceRoleFromNotation or from the moved piece
          final movedPieceRole = pieceRoleFromNotation ?? currentFromCell.figure?.role;
          if (movedPieceRole != null) {
            // Rebuild notation with piece type
            moveWithPiece = PieceNotation.createMoveNotation(movedPieceRole, fromStr, toStr);
          }
        }
        
        final updatedMoveHistory = [...state.moveHistory, moveWithPiece];
        state = state.copyWith(moveHistory: updatedMoveHistory);
        AppLogger.info('Move history updated. Total moves: ${updatedMoveHistory.length}. Latest: $moveWithPiece', tag: 'GameController');
        
        // Restart timer for new turn
        AppLogger.debug('Step 9: Restarting timer', tag: 'GameController');
        _restartTimerCountdown();
        
        AppLogger.info('=== _processOpponentMove SUCCESS ===', tag: 'GameController');
      } catch (e, stackTrace) {
        AppLogger.error('=== _processOpponentMove ERROR IN MOVE APPLICATION ===', tag: 'GameController', error: e, stackTrace: stackTrace);
        AppLogger.error('Error occurred while applying move, but connection will remain open', tag: 'GameController');
        // Re-throw to be caught by outer try-catch in WebSocket listener
        rethrow;
      }
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
        final timeOutSide = currentState.currentOrder;
        AppLogger.warning('Time out for ${timeOutSide.name} - ending game', tag: 'GameController');
        
        // Set to 0 to avoid negative values
        if (timeOutSide == Side.light) {
          state = currentState.copyWith(lightPlayerTimeSeconds: 0);
        } else {
          state = currentState.copyWith(darkPlayerTimeSeconds: 0);
        }
        
        // End the game - the player whose time expired loses, opponent wins
        if (!currentState.gameOver) {
          _endGameWithTimeOut(timeOutSide);
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

    // Check for checkmate/stalemate: if king has 0 available moves, check if any other pieces can move
    if (fromCell.figure?.role == Role.king && availableHashes.isEmpty) {
      AppLogger.info(
        'King has 0 moves. Checking if side has any legal moves...',
        tag: 'GameController'
      );
      final hasLegalMoves = ActionChecker.hasAnyLegalMoves(state.board, movingSide);
      if (!hasLegalMoves) {
        if (isInCheck) {
          // Checkmate - the side has no legal moves and king is in check
          AppLogger.warning(
            'CHECKMATE! ${movingSide.name} has no legal moves and king is in check.',
            tag: 'GameController'
          );
          _endGameWithCheckmate(movingSide);
        } else {
          // Stalemate - the side has no legal moves but king is not in check
          AppLogger.warning(
            'STALEMATE! ${movingSide.name} has no legal moves but king is not in check.',
            tag: 'GameController'
          );
          _endGameWithStalemate(movingSide);
        }
        return; // Don't display any moves, game is over
      }
    }

    for (final hash in availableHashes) {
      final position = hash.toPosition();
      final target = state.board.getCellAt(position.row, position.col);

      // CRITICAL: Never mark a cell as available if it contains our own piece
      if (target.isOccupied &&
          target.figure != null &&
          fromCell.figure != null &&
          target.figure!.side == fromCell.figure!.side) {
        AppLogger.warning(
          'Skipping marking own piece cell as available: '
          'from=${fromCell.positionHash} (${fromCell.figure?.role}) -> '
          'target=${target.positionHash} (${target.figure?.role})',
          tag: 'GameController'
        );
        continue; // Skip this cell - don't mark it as available
      }

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
    AppLogger.info(
      '=== GameController.showAvailableActions START ===',
      tag: 'GameController'
    );
    AppLogger.info(
      'fromCell: ${fromCell.position.algebraicPosition}, '
      'role: ${fromCell.figure?.role}, '
      'isSelected: ${fromCell.isSelected}',
      tag: 'GameController'
    );
    AppLogger.info(
      'Current selectedFigure before: ${state.selectedFigure}',
      tag: 'GameController'
    );
    
    // Only allow selecting pieces when it's the player's turn
    if (state.currentOrder != state.playerSide) {
      AppLogger.info(
        'Cannot select piece - not player\'s turn. Current order: ${state.currentOrder.name}, Player side: ${state.playerSide.name}',
        tag: 'GameController'
      );
      AppLogger.info(
        '=== GameController.showAvailableActions END (not player\'s turn) ===',
        tag: 'GameController'
      );
      return;
    }
    
    // Only allow selecting own pieces
    if (fromCell.figure == null || fromCell.figure!.side != state.playerSide) {
      final pieceSideName = fromCell.figure?.side.name ?? 'null';
      AppLogger.info(
        'Cannot select piece - not player\'s piece. Piece side: $pieceSideName, Player side: ${state.playerSide.name}',
        tag: 'GameController'
      );
      AppLogger.info(
        '=== GameController.showAvailableActions END (not player\'s piece) ===',
        tag: 'GameController'
      );
      return;
    }
    
    // Check if we're clicking on the same cell that's already selected
    final pressedCellHash = fromCell.positionHash;
    final isSameCell = state.selectedFigure == pressedCellHash;
    
    if (isSameCell && state.selectedFigure != null) {
      // User clicked on the same selected cell - deselect it and hide moves
      AppLogger.info(
        'Same cell clicked again - deselecting and clearing available moves',
        tag: 'GameController'
      );
      state.board.removeSelection();
      state = state.copyWith(selectedFigure: null);
      AppLogger.info(
        '=== GameController.showAvailableActions END (deselected) ===',
        tag: 'GameController'
      );
      return;
    }
    
    // Wipe selected cells before selecting a new one
    if (state.selectedFigure != null) {
      AppLogger.info(
        'Clearing previous selection: ${state.selectedFigure}',
        tag: 'GameController'
      );
      
      // Get the previously selected cell to log what we're clearing
      final prevSelectedHash = state.selectedFigure!;
      // Parse position hash (format: "row-col")
      final parts = prevSelectedHash.split('-');
      final prevSelectedRow = int.parse(parts[0]);
      final prevSelectedCol = int.parse(parts[1]);
      final prevSelectedCell = state.board.getCellAt(prevSelectedRow, prevSelectedCol);
      AppLogger.info(
        'Previous selection details: position=${prevSelectedHash}, '
        'role=${prevSelectedCell.figure?.role}, '
        'isSelected=${prevSelectedCell.isSelected}, '
        'isAvailable=${prevSelectedCell.isAvailable}',
        tag: 'GameController'
      );
      
      // Clear selection state first
      state = state.copyWith(selectedFigure: null);
      
      // Then clear board visual indicators
      state.board.removeSelection();
      
      AppLogger.info(
        'After removeSelection: checking if board state was cleared',
        tag: 'GameController'
      );
      
      // Verify the board was cleared
      final afterClearCell = state.board.getCellAt(prevSelectedRow, prevSelectedCol);
      AppLogger.info(
        'After clearing - prev cell state: isSelected=${afterClearCell.isSelected}, '
        'isAvailable=${afterClearCell.isAvailable}, '
        'canBeKnockedDown=${afterClearCell.canBeKnockedDown}',
        tag: 'GameController'
      );
      
      // Also check the new cell we're about to select
      AppLogger.info(
        'New cell to select - before: isSelected=${fromCell.isSelected}, '
        'isAvailable=${fromCell.isAvailable}, '
        'canBeKnockedDown=${fromCell.canBeKnockedDown}',
        tag: 'GameController'
      );
    }

    // Get fresh cell state after clearing (in case it changed)
    final freshFromCell = state.board.getCellAt(fromCell.row, fromCell.col);
    AppLogger.info(
      'Fresh cell state after clearing: isSelected=${freshFromCell.isSelected}, '
      'isAvailable=${freshFromCell.isAvailable}, '
      'figure=${freshFromCell.figure?.role}',
      tag: 'GameController'
    );
    
    // Select the new cell and show available moves
    AppLogger.info(
      'Selecting new cell and displaying available moves',
      tag: 'GameController'
    );
    _displayAvailableCells(freshFromCell);
    
    // Update selection state - selecting the cell
    state.board.updateCell(freshFromCell.row, freshFromCell.col,
        (cell) => cell.copyWith(isSelected: true));
    state = state.copyWith(selectedFigure: freshFromCell.positionHash);
    
    // Verify final state
    final finalCell = state.board.getCellAt(freshFromCell.row, freshFromCell.col);
    AppLogger.info(
      'Final cell state: isSelected=${finalCell.isSelected}, '
      'isAvailable=${finalCell.isAvailable}, '
      'figure=${finalCell.figure?.role}',
      tag: 'GameController'
    );
    AppLogger.info(
      'New selectedFigure after: ${state.selectedFigure}',
      tag: 'GameController'
    );
    AppLogger.info(
      '=== GameController.showAvailableActions END ===',
      tag: 'GameController'
    );
  }

  /// Convert FEN row (1-8, white's perspective) to internal row (0-7)
  /// When player is black, the board is flipped: white pieces at rows 0-1, black at rows 6-7
  int _convertFenRowToInternalRow(int fenRow, Side playerSide) {
    if (playerSide == Side.light) {
      // Player is white: simple conversion
      // FEN row 1 (white back rank) → internal row 7 (player back rank)
      // FEN row 8 (black back rank) → internal row 0 (opponent back rank)
      return 8 - fenRow;
    } else {
      // Player is black: board is flipped
      // Internal board: row 0-1 = white (opponent), row 6-7 = black (player)
      // FEN notation: row 1-2 = white, row 7-8 = black
      //
      // The board is flipped, so we need to mirror the rows:
      // FEN row 1 (white back) → internal row 0 (opponent back) = 1-1 = 0
      // FEN row 2 (white pawn) → internal row 1 (opponent pawn) = 2-1 = 1
      // FEN row 3 → internal row 5 (flipped: 8-3=5, but we need to account for flip)
      // FEN row 4 → internal row 3 (flipped: 8-4=4, but we need to account for flip)
      // FEN row 5 → internal row 2 (flipped: 8-5=3, but we need to account for flip)
      // FEN row 6 → internal row 2 (flipped: 8-6=2, but we need to account for flip)
      // FEN row 7 (black pawn) → internal row 6 (player pawn) = 7-1 = 6
      // FEN row 8 (black back) → internal row 7 (player back) = 8-1 = 7
      //
      // Actually, the correct formula for flipped board is:
      // For rows 1-2: fenRow - 1 (direct mapping to opponent side)
      // For rows 7-8: fenRow - 1 (direct mapping to player side)
      // For rows 3-6: we need to flip them
      //   FEN row 3 → internal row 5 (closer to player side)
      //   FEN row 4 → internal row 4 (middle)
      //   FEN row 5 → internal row 3 (closer to opponent side)
      //   FEN row 6 → internal row 2 (closer to opponent side)
      //
      // The pattern: for middle rows, we flip: internalRow = 7 - (fenRow - 1) = 8 - fenRow
      // But wait, that gives: row 3→5, row 4→4, row 5→3, row 6→2, which matches!
      if (fenRow <= 2) {
        // White pieces (opponent): FEN row 1-2 → internal row 0-1
        return fenRow - 1;
      } else if (fenRow >= 7) {
        // Black pieces (player): FEN row 7-8 → internal row 6-7
        return fenRow - 1;
      } else {
        // Middle rows (3-6): linear mapping
        // When player is black, the board is visually flipped but internal representation is linear
        // FEN row 3 (closer to white in FEN) → internal row 2 (closer to white/opponent)
        // FEN row 4 → internal row 3
        // FEN row 5 → internal row 4
        // FEN row 6 (closer to black in FEN) → internal row 5 (closer to black/player)
        // The pattern: internalRow = fenRow - 1 (same as rows 1-2 and 7-8)
        return fenRow - 1;
      }
    }
  }

  /// Return the result is Opponents move has a correct status
  ///
  Future<bool> makeOpponentsMove() async {
    AppLogger.info('=== GameController.makeOpponentsMove() START ===', tag: 'GameController');
    AppLogger.info('Current game state:', tag: 'GameController');
    AppLogger.info('  - Current order (whose turn): ${state.currentOrder}', tag: 'GameController');
    AppLogger.info('  - Player side: ${state.playerSide}', tag: 'GameController');
    final opponentSide = state.playerSide.opposite;
    AppLogger.info('  - Opponent side: $opponentSide', tag: 'GameController');
    
    // Verify it's actually the opponent's turn
    if (state.currentOrder != opponentSide) {
      AppLogger.warning('=== makeOpponentsMove() ABORTED: Not opponent\'s turn ===', tag: 'GameController');
      AppLogger.warning('  - Current order: ${state.currentOrder.name}, Expected: ${opponentSide.name}', tag: 'GameController');
      AppLogger.warning('  - This should not happen - AI move triggered at wrong time', tag: 'GameController');
      return false;
    }
    
    // Verify game is not over
    if (state.gameOver) {
      AppLogger.warning('=== makeOpponentsMove() ABORTED: Game is already over ===', tag: 'GameController');
      return false;
    }
    
    try {
      // Ensure board state is synced before getting opponent move
      // After a player move, we need to verify Stockfish's board state matches our game state
      AppLogger.info('Step 1: Verifying board state is synced', tag: 'GameController');
      await actionHandler.visualizeBoard();
      
      // For AI games, verify the FEN position matches our game state
      // This ensures Stockfish knows whose turn it is
      if (GameModesMediator.opponentMode == OpponentMode.ai) {
        // Get current FEN from Stockfish to verify turn
        final aiHandler = actionHandler;
        if (aiHandler is AIActionHandler) {
          try {
            final currentFen = await aiHandler.getFenPosition();
            AppLogger.info('Current FEN from Stockfish: $currentFen', tag: 'GameController');
            
            // Extract whose turn it is from FEN (last part before castling rights)
            // FEN format: "pieces placement turn castling en passant halfmove fullmove"
            final fenParts = currentFen.split(' ');
            if (fenParts.length >= 2) {
              final turnInFen = fenParts[1]; // 'w' for white, 'b' for black
              final expectedTurn = state.currentOrder.isLight ? 'w' : 'b';
              
              AppLogger.info('FEN turn: $turnInFen, Expected turn: $expectedTurn', tag: 'GameController');
              
              if (turnInFen != expectedTurn) {
                AppLogger.warning(
                  'Board state mismatch detected! FEN shows $turnInFen but game state shows ${state.currentOrder.name}',
                  tag: 'GameController'
                );
                AppLogger.warning(
                  'Rebuilding Stockfish board state from move history...',
                  tag: 'GameController'
                );
                // Rebuild board from move history to fix the mismatch
                await aiHandler.rebuildBoardFromMoves(state.moveHistory);
                
                // Verify the fix worked
                final fenAfterRebuild = await aiHandler.getFenPosition();
                final fenPartsAfter = fenAfterRebuild.split(' ');
                if (fenPartsAfter.length >= 2) {
                  final turnAfterRebuild = fenPartsAfter[1];
                  AppLogger.info(
                    'After rebuild: FEN turn: $turnAfterRebuild, Expected: $expectedTurn',
                    tag: 'GameController'
                  );
                  if (turnAfterRebuild != expectedTurn) {
                    AppLogger.error(
                      'Board rebuild failed! FEN still shows wrong turn: $turnAfterRebuild',
                      tag: 'GameController'
                    );
                  }
                }
              }
            }
          } catch (e) {
            AppLogger.warning('Could not verify FEN position: $e', tag: 'GameController');
            // Continue anyway - the move request might still work
          }
        }
      }
      
      AppLogger.info('Board state verification completed', tag: 'GameController');
      
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
      // Stockfish returns moves in format "e2e4" (4 chars) or potentially "Pe2e4" (5 chars with piece)
      // Parse the move notation properly to handle both formats
      final parsedMove = PieceNotation.parseMoveNotation(bestAction!);
      final fromNotation = parsedMove['from'] as String? ?? '';
      final toNotation = parsedMove['to'] as String? ?? '';
      
      if (fromNotation.isEmpty || toNotation.isEmpty) {
        AppLogger.error('Failed to parse move notation: $bestAction', tag: 'GameController');
        AppLogger.error('Parsed result: from=$fromNotation, to=$toNotation', tag: 'GameController');
        return false;
      }
      
      AppLogger.info('Parsed move: from=$fromNotation, to=$toNotation', tag: 'GameController');
      
      // Parse algebraic notation
      final fromCol = boardLetters.indexOf(fromNotation[0]);
      final fromRowFen = int.parse(fromNotation[1]);
      final toCol = boardLetters.indexOf(toNotation[0]);
      final toRowFen = int.parse(toNotation[1]);
      
      // Convert FEN row (1-8, white's perspective) to internal row (0-7)
      // The board is always: row 0-1 = opponent, row 6-7 = player
      // 
      // If player is WHITE:
      //   - FEN row 1-2 (white) → internal row 6-7 (player): 8 - fenRow
      //   - FEN row 7-8 (black) → internal row 0-1 (opponent): 8 - fenRow
      //
      // If player is BLACK:
      //   - FEN row 1-2 (white) → internal row 0-1 (opponent): fenRow - 1
      //   - FEN row 7-8 (black) → internal row 6-7 (player): need different formula
      //     FEN row 7 → internal row 6: if 8-7=1, then 6 = 1+5, so (8-fenRow)+5
      //     FEN row 8 → internal row 7: if 8-8=0, then 7 = 0+7, so (8-fenRow)+7
      //     But that's inconsistent. Let me try: internalRow = 13 - fenRow
      //     Row 7: 13-7=6 ✓, Row 8: 13-8=5 ✗
      //     Or: internalRow = 15 - fenRow
      //     Row 7: 15-7=8 ✗ (out of bounds), Row 8: 15-8=7 ✓
      //     
      //     Actually, the correct formula is: internalRow = (8 - fenRow) + 6 for row 7-8
      //     Row 7: (8-7)+6 = 1+6 = 7 ✗ (should be 6)
      //     Row 8: (8-8)+6 = 0+6 = 6 ✗ (should be 7)
      //     
      //     Let me try: internalRow = (8 - fenRow) + 5 for row 7, + 7 for row 8
      //     That's too complex. Let me use a simpler approach:
      //     For row 7-8 when player is black: internalRow = 13 - fenRow for row 7, 15 - fenRow for row 8
      //     But that's also complex.
      //     
      //     Actually, I think the simplest is: if fenRow >= 7, use 13 - fenRow, but that gives wrong for row 8
      //     Or: if fenRow == 7, use 6; if fenRow == 8, use 7
      //     That's: internalRow = 13 - fenRow for row 7, but 13-8=5 is wrong
      //     
      //     Let me check: maybe the board layout is actually different than I think.
      //     Actually, wait - let me verify: if player is black and FEN row 7 maps to internal row 1 with 8-fenRow,
      //     and row 1 has black pieces (player), then maybe the board IS set up that way?
      //     But the logs show row 6 has black pieces, not row 1.
      //     
      //     I think the issue is that I need to check the actual board state.
      //     For now, let me use: if fenRow >= 7, internalRow = 13 - fenRow, and handle row 8 specially
      // Convert FEN row (1-8, white's perspective) to internal row (0-7)
      final fromRow = _convertFenRowToInternalRow(fromRowFen, state.playerSide);
      final toRow = _convertFenRowToInternalRow(toRowFen, state.playerSide);
      
      // Validate the conversion
      if (fromRow < 0 || fromRow > 7 || toRow < 0 || toRow > 7) {
        AppLogger.error(
          'Invalid row conversion: FEN fromRow=$fromRowFen -> internalRow=$fromRow, FEN toRow=$toRowFen -> internalRow=$toRow',
          tag: 'GameController'
        );
        return false;
      }
      
      final fromPosition = Position(row: fromRow, col: fromCol);
      final targetPosition = Position(row: toRow, col: toCol);
      
      AppLogger.info('  - Player side: ${state.playerSide.name}', tag: 'GameController');
      AppLogger.info('  - From position: $fromNotation (FEN row $fromRowFen) -> internal row ${fromPosition.row}, col ${fromPosition.col}', tag: 'GameController');
      AppLogger.info('  - To position: $toNotation (FEN row $toRowFen) -> internal row ${targetPosition.row}, col ${targetPosition.col}', tag: 'GameController');

      final fromCell = state.board.getCellAt(fromPosition.row, fromPosition.col);
      final targetCell =
          state.board.getCellAt(targetPosition.row, targetPosition.col);
      
      AppLogger.info('  - From cell: row ${fromCell.position.row}, col ${fromCell.position.col}, algebraic=${fromCell.position.algebraicPosition}', tag: 'GameController');
      AppLogger.info('  - From cell isOccupied: ${fromCell.isOccupied}, figure: ${fromCell.figure?.role}, side: ${fromCell.figure?.side}', tag: 'GameController');
      AppLogger.info('  - To cell: row ${targetCell.position.row}, col ${targetCell.position.col}, algebraic=${targetCell.position.algebraicPosition}', tag: 'GameController');
      AppLogger.info('  - To cell isOccupied: ${targetCell.isOccupied}, figure: ${targetCell.figure?.role}', tag: 'GameController');

      // Check if the move is valid before executing
      AppLogger.info('Step 4: Validating move', tag: 'GameController');
      if (fromCell.figure == null) {
        AppLogger.warning('=== makeOpponentsMove() FAILED: No figure at source position ===', tag: 'GameController');
        AppLogger.warning('  - Source position (absolute): $fromNotation', tag: 'GameController');
        AppLogger.warning('  - Source position (internal): row ${fromPosition.row}, col ${fromPosition.col}', tag: 'GameController');
        AppLogger.warning('  - Source position (algebraic): ${fromCell.position.algebraicPosition}', tag: 'GameController');
        AppLogger.warning('  - Cell is empty', tag: 'GameController');
        AppLogger.warning('  - Player side: ${state.playerSide.name}, Current order: ${state.currentOrder.name}', tag: 'GameController');
        AppLogger.warning('  - This suggests a board state mismatch with Stockfish', tag: 'GameController');
        
        // Try to find the piece that should be at this position by checking nearby cells
        AppLogger.warning('  - Checking nearby cells for the expected piece...', tag: 'GameController');
        for (int r = 0; r < 8; r++) {
          for (int c = 0; c < 8; c++) {
            final cell = state.board.getCellAt(r, c);
            if (cell.figure != null && cell.figure!.side == state.currentOrder) {
              AppLogger.warning('    Found ${cell.figure!.side.name} ${cell.figure!.role} at row $r, col $c (${cell.position.algebraicPosition})', tag: 'GameController');
            }
          }
        }
        
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

      // Create move notation with piece type
      // Stockfish returns moves in absolute notation (white's perspective)
      // We should use absolute notation for both Stockfish and move history to ensure consistency
      final pieceRole = fromCell.figure!.role;
      
      // Use absolute notation for Stockfish (fromNotation and toNotation are already in absolute notation)
      final actionForStockfish = PieceNotation.createMoveNotation(pieceRole, fromNotation, toNotation);
      
      // Use absolute notation for move history as well (same as Stockfish)
      // This ensures the displayed move matches what Stockfish actually played
      final actionForHistory = actionForStockfish;
      
      AppLogger.info('Step 6: Created move notation - Stockfish: $actionForStockfish, History: $actionForHistory (piece: ${pieceRole.name})', tag: 'GameController');
      AppLogger.info('  - From notation (absolute): $fromNotation, To notation (absolute): $toNotation', tag: 'GameController');
      AppLogger.info('  - From position (internal): row=${fromPosition.row}, col=${fromPosition.col}', tag: 'GameController');
      AppLogger.info('  - To position (internal): row=${targetPosition.row}, col=${targetPosition.col}', tag: 'GameController');
      AppLogger.info('  - Note: Move stored in absolute notation ($actionForHistory) for consistency with Stockfish', tag: 'GameController');

      AppLogger.info('Step 7: Executing opponent move via action', tag: 'GameController');
      // Use absolute notation for Stockfish, but pass history notation separately
      final success = await _makeMoveViaAction(actionForStockfish, fromCell, targetCell, isPlayerMove: false, historyNotation: actionForHistory);
      if (success) {
        AppLogger.info('=== GameController.makeOpponentsMove() SUCCESS ===', tag: 'GameController');
        AppLogger.info('Opponent move executed successfully: $actionForHistory (piece: ${pieceRole.name})', tag: 'GameController');
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
    AppLogger.info(
      '=== GameController._getSelectedCell START ===',
      tag: 'GameController'
    );
    AppLogger.info(
      'from parameter: ${from?.positionHash}, '
      'target: ${target.positionHash}, '
      'selectedFigure: ${state.selectedFigure}',
      tag: 'GameController'
    );
    
    if (from != null) {
      AppLogger.info(
        'Using from parameter: ${from.positionHash}, role=${from.figure?.role}',
        tag: 'GameController'
      );
      AppLogger.info(
        '=== GameController._getSelectedCell END (from param) ===',
        tag: 'GameController'
      );
      return from;
    }

    if (state.selectedFigure != null) {
      // Parse position hash (format: "row-col")
      final parts = state.selectedFigure!.split('-');
      final selectedRow = int.parse(parts[0]);
      final selectedCol = int.parse(parts[1]);
      final selectedCell = board.getCellAt(selectedRow, selectedCol);
      
      AppLogger.info(
        'Using selectedFigure: ${state.selectedFigure} -> '
        'row=$selectedRow, col=$selectedCol, '
        'role=${selectedCell.figure?.role}, '
        'side=${selectedCell.figure?.side}',
        tag: 'GameController'
      );
      AppLogger.info(
        '=== GameController._getSelectedCell END (selectedFigure) ===',
        tag: 'GameController'
      );
      return selectedCell;
    }

    AppLogger.info(
      'No selection, using target: ${target.positionHash}, role=${target.figure?.role}',
      tag: 'GameController'
    );
    AppLogger.info(
      '=== GameController._getSelectedCell END (target) ===',
      tag: 'GameController'
    );
    return target;
  }

  /// Return the result is Opponents move has a correct status
  ///
  Future<bool> makeMove(Cell target, {Cell? from}) async {
    AppLogger.info(
      '=== GameController.makeMove START ===',
      tag: 'GameController'
    );
    AppLogger.info(
      'target: ${target.position.algebraicPosition}, '
      'from parameter: ${from?.position.algebraicPosition}, '
      'selectedFigure: ${state.selectedFigure}',
      tag: 'GameController'
    );
    
    // Check if it's the player's turn
    if (state.currentOrder != state.playerSide) {
      AppLogger.warning(
        'Cannot make move - not player\'s turn. Current order: ${state.currentOrder.name}, Player side: ${state.playerSide.name}',
        tag: 'GameController'
      );
      AppLogger.info(
        '=== GameController.makeMove END (not player\'s turn) ===',
        tag: 'GameController'
      );
      return false;
    }
    
    final board = state.board;
    final selectedCell = _getSelectedCell(board, target, from: from);
    
    AppLogger.info(
      'selectedCell: ${selectedCell.position.algebraicPosition}, '
      'role: ${selectedCell.figure?.role}, '
      'side: ${selectedCell.figure?.side}',
      tag: 'GameController'
    );
    AppLogger.info(
      'target cell isAvailable: ${target.isAvailable}, '
      'canBeKnockedDown: ${target.canBeKnockedDown}, '
      'isOccupied: ${target.isOccupied}, '
      'targetPiece: ${target.figure?.role}, '
      'targetPieceSide: ${target.figure?.side}',
      tag: 'GameController'
    );

    // CRITICAL SAFETY CHECK: Never allow moving to a cell with our own piece
    if (target.isOccupied &&
        target.figure != null &&
        selectedCell.figure != null &&
        target.figure!.side == selectedCell.figure!.side) {
      AppLogger.error(
        'BLOCKED INVALID MOVE: Attempting to move ${selectedCell.figure!.role} '
        'from ${selectedCell.position.algebraicPosition} to ${target.position.algebraicPosition} '
        'which contains own piece ${target.figure!.role}!',
        tag: 'GameController'
      );
      AppLogger.info(
        '=== GameController.makeMove END (blocked - own piece) ===',
        tag: 'GameController'
      );
      return false;
    }

    final isMoveAvailable = selectedCell.moveFigure(board, target);
    if (!isMoveAvailable) {
      AppLogger.warning(
        'Move not available: ${selectedCell.position.algebraicPosition} -> ${target.position.algebraicPosition}',
        tag: 'GameController'
      );
      AppLogger.info(
        '=== GameController.makeMove END (not available) ===',
        tag: 'GameController'
      );
      return false;
    }

    // Get piece role BEFORE move (piece will move after makeMove)
    final pieceRole = selectedCell.figure!.role;
    
    // For AI games, use absolute notation for AI (no column reversal)
    // For online games, use absolute notation (with column reversal for black)
    final fromPos = GameModesMediator.opponentMode == OpponentMode.ai
        ? selectedCell.position.absoluteAlgebraicPositionForAI
        : selectedCell.position.absoluteAlgebraicPosition;
    final toPos = GameModesMediator.opponentMode == OpponentMode.ai
        ? target.position.absoluteAlgebraicPositionForAI
        : target.position.absoluteAlgebraicPosition;
    
    // Debug: Log the coordinate conversion with detailed information
    final playerSide = PlayerSideMediator.playerSide;
    final selectedAlgebraic = selectedCell.position.algebraicPosition;
    final targetAlgebraic = target.position.algebraicPosition;
    AppLogger.info(
      'Coordinate conversion: '
      'selectedCell(row=${selectedCell.position.row}, col=${selectedCell.position.col}, '
      'algebraic=$selectedAlgebraic) -> $fromPos, '
      'target(row=${target.position.row}, col=${target.position.col}, '
      'algebraic=$targetAlgebraic) -> $toPos, '
      'playerSide=${playerSide.name}',
      tag: 'GameController'
    );
    
    // Create move notation with piece type: "Pe2e4", "Ne2f4", etc.
    final action = PieceNotation.createMoveNotation(pieceRole, fromPos, toPos);
    AppLogger.info('Making move: $action (absolute notation, piece: ${pieceRole.name})', tag: 'GameController');

    // Capture is already handled by moveFigure, so skip it in _makeMoveViaAction
    final success = await _makeMoveViaAction(action, selectedCell, target, skipCapture: true);
    if (success) {
      AppLogger.info('Move executed successfully: $action', tag: 'GameController');
    } else {
      AppLogger.warning('Failed to execute move: $action', tag: 'GameController');
    }
    AppLogger.info(
      '=== GameController.makeMove END (success: $success) ===',
      tag: 'GameController'
    );
    return success;
  }

  /// Get [action] and make move according to it
  /// [isPlayerMove] indicates if this is a player move (true) or opponent move (false)
  /// This is used to determine whether to trigger AI moves after the move completes
  ///
  Future<bool> _makeMoveViaAction(
      String action, Cell selectedCell, Cell targetCell, {bool skipCapture = false, bool isPlayerMove = true, String? historyNotation}) async {
    AppLogger.debug('Executing move via action: $action', tag: 'GameController');
    
    // Store the move notation we're about to send (for online games to filter echoes)
    if (GameModesMediator.opponentMode == OpponentMode.socket) {
      _lastSentMoveNotation = action;
      AppLogger.debug('Stored sent move notation: $action (to filter echo)', tag: 'GameController');
    }
    
    try {
      await actionHandler.makeMove(action);
      AppLogger.debug('Move sent to action handler', tag: 'GameController');
    } catch (e) {
      AppLogger.error('Error sending move to action handler: $e', tag: 'GameController', error: e);
      _lastSentMoveNotation = null; // Clear on error
      return false;
    }

    // Get auto-queen setting
    final settingsAsync = ref.read(settingsControllerProvider);
    final autoQueen = settingsAsync.valueOrNull?.autoQueen ?? true;
    final selectedEffect = settingsAsync.valueOrNull?.effect ?? 'classic';

    // Check if target cell has a piece that will be captured
    final capturedFigure = !skipCapture && targetCell.isOccupied ? targetCell.figure : null;
    final isCapture = capturedFigure != null;

    // Handle capture before making the move (only if not already handled by moveFigure)
    if (isCapture) {
      state.board.pushKnockedFigure(capturedFigure);
      AppLogger.info(
        'Piece captured: ${capturedFigure.role} (${capturedFigure.side})',
        tag: 'GameController',
      );
    }

    // Log move execution details
    AppLogger.info(
      'Executing move on board: fromCell(row=${selectedCell.position.row}, col=${selectedCell.position.col}, '
      'algebraic=${selectedCell.position.algebraicPosition}) -> '
      'toCell(row=${targetCell.position.row}, col=${targetCell.position.col}, '
      'algebraic=${targetCell.position.algebraicPosition}), '
      'playerSide=${PlayerSideMediator.playerSide.name}',
      tag: 'GameController'
    );
    
    final updatedBoard = state.board
      ..makeMove(selectedCell, targetCell, autoQueen: autoQueen)
      ..removeSelection();
    
    // Verify the move was executed correctly
    AppLogger.info(
      'After move execution: fromCell isOccupied=${selectedCell.isOccupied}, '
      'toCell isOccupied=${targetCell.isOccupied}, toCell figure=${targetCell.figure?.role}',
      tag: 'GameController'
    );

    // Emit effect event for the move
    if (isCapture) {
      // Emit capture effect
      _effectEventController.add(EffectEvent(
        type: EffectEventType.capture,
        effectName: selectedEffect,
        fromPosition: selectedCell.position,
        toPosition: targetCell.position,
      ));
    } else {
      // Emit move effect
      _effectEventController.add(EffectEvent(
        type: EffectEventType.move,
        effectName: selectedEffect,
        fromPosition: selectedCell.position,
        toPosition: targetCell.position,
      ));
    }

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
    
    // Check for checkmate or stalemate after the move
    if (ActionChecker.isCheckmate(updatedBoard, newCurrentOrder)) {
      AppLogger.warning(
        'CHECKMATE detected after move! ${newCurrentOrder.name} is checkmated.',
        tag: 'GameController'
      );
      _endGameWithCheckmate(newCurrentOrder);
      return true;
    } else if (ActionChecker.isStalemate(updatedBoard, newCurrentOrder)) {
      AppLogger.warning(
        'STALEMATE detected after move! ${newCurrentOrder.name} is stalemated.',
        tag: 'GameController'
      );
      _endGameWithStalemate(newCurrentOrder);
      return true;
    }
    
    // For AI games, trigger opponent move after player move (not after opponent moves)
    // For online games, opponent moves come via WebSocket
    final opponentMode = GameModesMediator.opponentMode;
    final opponentSide = state.playerSide.opposite;
    if (isPlayerMove && opponentMode == OpponentMode.ai && newCurrentOrder == opponentSide) {
      AppLogger.info('Triggering AI opponent move after player move', tag: 'GameController');
      AppLogger.info('  - Player side: ${state.playerSide.name}, Opponent side: $opponentSide, New current order: ${newCurrentOrder.name}', tag: 'GameController');
      // Trigger opponent move asynchronously
      Future.microtask(() => makeOpponentsMove());
    } else if (!isPlayerMove) {
      AppLogger.debug('Skipping AI trigger - this was an opponent move', tag: 'GameController');
    }
    
    // Restart timer for new turn
    _restartTimerCountdown();

    // Use historyNotation if provided, otherwise use action
    final notationForHistory = historyNotation ?? action;
    
    actionLogger.add(action);
    AppLogger.debug('Move logged: $action (history: $notationForHistory)', tag: 'GameController');
    
    // Update move history in state (use historyNotation if provided for player perspective display)
    final updatedMoveHistory = [...state.moveHistory, notationForHistory];
    state = state.copyWith(
      moveHistory: updatedMoveHistory,
    );
    AppLogger.info('Move history updated. Total moves: ${updatedMoveHistory.length}. Latest: $notationForHistory', tag: 'GameController');

    return true;
  }

  void dispose() {
    AppLogger.info('Disposing GameController', tag: 'GameController');
    _timerCountdown?.cancel();
    _websocketSubscription?.cancel();
    _effectEventController.close();
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

  /// Send surrender message to opponent (for online games)
  Future<void> sendSurrender() async {
    if (actionHandler is SocketActionHandler) {
      AppLogger.info('Sending surrender message via GameController', tag: 'GameController');
      await (actionHandler as SocketActionHandler).sendSurrender();
    } else {
      AppLogger.warning('Cannot send surrender: not in online mode', tag: 'GameController');
    }
  }

  /// End the game with checkmate
  /// [losingSide] is the side that was checkmated (lost)
  void _endGameWithCheckmate(Side losingSide) {
    final winningSide = losingSide.opposite;
    
    AppLogger.info(
      'Game Over: ${winningSide.name} wins by checkmate. ${losingSide.name} loses.',
      tag: 'GameController'
    );
    
    // Stop the timer
    _timerCountdown?.cancel();
    
    // Update state to mark game as over
    state = state.copyWith(
      gameOver: true,
      winner: winningSide,
      isCheckmate: true,
      isStalemate: false,
    );
  }

  /// End the game with stalemate
  /// [stalematedSide] is the side that was stalemated (draw)
  void _endGameWithStalemate(Side stalematedSide) {
    AppLogger.info(
      'Game Over: Stalemate! ${stalematedSide.name} has no legal moves but is not in check.',
      tag: 'GameController'
    );
    
    // Stop the timer
    _timerCountdown?.cancel();
    
    // Update state to mark game as over (stalemate is a draw, no winner)
    state = state.copyWith(
      gameOver: true,
      winner: null, // No winner in stalemate (draw)
      isCheckmate: false,
      isStalemate: true,
    );
  }

  /// End the game with surrender
  /// [surrenderingSide] is the side that surrendered (lost)
  void _endGameWithSurrender(Side surrenderingSide) {
    final winningSide = surrenderingSide.opposite;
    
    AppLogger.info(
      'Game Over: ${surrenderingSide.name} surrendered. ${winningSide.name} wins.',
      tag: 'GameController'
    );
    AppLogger.info(
      'Player side: ${state.playerSide.name}, Winning side: ${winningSide.name}, Player won: ${winningSide == state.playerSide}',
      tag: 'GameController'
    );
    
    // Stop the timer
    _timerCountdown?.cancel();
    
    // Update state to mark game as over
    // Use a new state object to ensure Riverpod detects the change
    final newState = state.copyWith(
      gameOver: true,
      winner: winningSide,
      isCheckmate: false,
      isStalemate: false,
    );
    state = newState;
    
    AppLogger.info(
      'State updated - gameOver: ${state.gameOver}, winner: ${state.winner?.name}, isCheckmate: ${state.isCheckmate}, isStalemate: ${state.isStalemate}',
      tag: 'GameController'
    );
  }

  /// End game when a player's time runs out
  /// The player whose time expired loses, the opponent wins
  void _endGameWithTimeOut(Side timeOutSide) {
    final winningSide = timeOutSide.opposite;
    
    AppLogger.info(
      'Game Over: Time out! ${timeOutSide.name} ran out of time. ${winningSide.name} wins!',
      tag: 'GameController'
    );
    
    // Cancel timer
    _timerCountdown?.cancel();
    
    // Update state to mark game as over
    state = state.copyWith(
      gameOver: true,
      winner: winningSide,
      isCheckmate: false,
      isStalemate: false,
    );
    
    AppLogger.info(
      'State updated - gameOver: ${state.gameOver}, winner: ${state.winner?.name}, reason: time_out',
      tag: 'GameController'
    );
  }
}
