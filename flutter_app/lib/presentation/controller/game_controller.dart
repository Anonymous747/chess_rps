import 'dart:async';

import 'package:chess_rps/common/enum.dart';
import 'package:chess_rps/common/extension.dart';
import 'package:chess_rps/common/logger.dart';
import 'package:chess_rps/common/piece_notation.dart';
import 'package:chess_rps/common/rps_choice.dart';
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

    // Connect to WebSocket and set up listener for online games
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
    _websocketSubscription = handler.messageStream.listen(
      (message) async {
        try {
          final type = message['type'] as String?;
          if (type == 'timer_update' || type == 'move' || type == 'room_joined' || type == 'player_left' || type == 'error') {
            // Handle player_left - log but don't interrupt game
            if (type == 'player_left') {
              AppLogger.warning('Received player_left message - opponent disconnected, but continuing game', tag: 'GameController');
              // Don't interrupt the game - just log it
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
        // When stream closes, try to reconnect or at least log it
        // Don't set _isConnected to false here - let the GameRoomHandler handle it
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
    
    // Wipe selected cells before follow action
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
    
    if (!freshFromCell.isSelected) {
      AppLogger.info(
        'Cell not selected, displaying available moves',
        tag: 'GameController'
      );
      _displayAvailableCells(freshFromCell);
    } else {
      AppLogger.info(
        'Cell already selected, deselecting',
        tag: 'GameController'
      );
    }

    // Update selection state
    final willBeSelected = !freshFromCell.isSelected;
    state.board.updateCell(freshFromCell.row, freshFromCell.col,
        (cell) => cell.copyWith(isSelected: willBeSelected));
    final newSelectedFigure = willBeSelected ? freshFromCell.positionHash : null;
    state = state.copyWith(selectedFigure: newSelectedFigure);
    
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
    
    // For online games, use absolute notation (from white's perspective)
    // This ensures both players interpret moves the same way
    final fromPos = GameModesMediator.opponentMode == OpponentMode.socket
        ? selectedCell.position.absoluteAlgebraicPosition
        : selectedCell.position.algebraicPosition;
    final toPos = GameModesMediator.opponentMode == OpponentMode.socket
        ? target.position.absoluteAlgebraicPosition
        : target.position.algebraicPosition;
    
    // Create move notation with piece type: "Pe2e4", "Ne2f4", etc.
    final action = PieceNotation.createMoveNotation(pieceRole, fromPos, toPos);
    AppLogger.info('Making move: $action (${GameModesMediator.opponentMode == OpponentMode.socket ? "absolute" : "relative"} notation, piece: ${pieceRole.name})', tag: 'GameController');

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
  ///
  Future<bool> _makeMoveViaAction(
      String action, Cell selectedCell, Cell targetCell, {bool skipCapture = false}) async {
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

    // Handle capture before making the move (only if not already handled by moveFigure)
    if (!skipCapture) {
      // Check if target cell has a piece that will be captured
      final capturedFigure = targetCell.isOccupied ? targetCell.figure : null;
      if (capturedFigure != null) {
        state.board.pushKnockedFigure(capturedFigure);
        AppLogger.info(
          'Piece captured: ${capturedFigure.role} (${capturedFigure.side})',
          tag: 'GameController',
        );
      }
    }

    final updatedBoard = state.board
      ..makeMove(selectedCell, targetCell, autoQueen: autoQueen)
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
    
    // For AI games, trigger opponent move after player move
    // For online games, opponent moves come via WebSocket
    final opponentMode = GameModesMediator.opponentMode;
    if (opponentMode == OpponentMode.ai && newCurrentOrder != state.playerSide) {
      AppLogger.info('Triggering AI opponent move after player move', tag: 'GameController');
      // Trigger opponent move asynchronously
      Future.microtask(() => makeOpponentsMove());
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
}
