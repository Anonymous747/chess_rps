import 'dart:async';
import 'dart:convert';
import 'package:chess_rps/common/enum.dart';
import 'package:chess_rps/common/logger.dart';
import 'package:chess_rps/common/palette.dart';
import 'package:chess_rps/data/service/socket/game_room_handler.dart';
import 'package:chess_rps/presentation/mediator/game_mode_mediator.dart';
import 'package:chess_rps/presentation/mediator/player_side_mediator.dart';
import 'package:chess_rps/presentation/utils/app_router.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class WaitingRoomScreen extends StatefulWidget {
  final String roomCode;

  const WaitingRoomScreen({
    Key? key,
    required this.roomCode,
  }) : super(key: key);

  @override
  State<WaitingRoomScreen> createState() => _WaitingRoomScreenState();
}

class _WaitingRoomScreenState extends State<WaitingRoomScreen> {
  final GameRoomHandler _roomHandler = GameRoomHandler();
  StreamSubscription? _messageSubscription;
  Timer? _heartbeatTimer; // Timer for periodic heartbeat checks
  bool _isWaiting = true;
  bool _isConnecting = true;
  String? _errorMessage;
  bool _hasNavigated = false; // Track if we've navigated to chess screen

  @override
  void initState() {
    super.initState();
    AppLogger.info('WaitingRoomScreen initialized for room: ${widget.roomCode}', tag: 'WaitingRoom');
    _connectToRoom();
  }

  void _navigateToGame([Map<String, dynamic>? opponentInfo]) {
    // Mark as navigated to prevent further message processing
    _hasNavigated = true;
    
    // Stop heartbeat timer since we're navigating away
    _heartbeatTimer?.cancel();
    _heartbeatTimer = null;
    
    // Store opponent info if provided
    if (opponentInfo != null) {
      GameModesMediator.setOpponentInfo(opponentInfo);
      AppLogger.info('Stored opponent info: ${opponentInfo['username']}, avatar: ${opponentInfo['avatar_icon']}', tag: 'WaitingRoom');
    }
    
    // Navigate to chess screen after a short delay
    // Store room code and handler in mediator so GameController can reuse the connection
    GameModesMediator.setRoomCode(widget.roomCode);
    GameModesMediator.setSharedRoomHandler(_roomHandler);
    AppLogger.info('Stored shared room handler for reuse', tag: 'WaitingRoom');
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        AppLogger.info('Navigating to chess screen with room: ${widget.roomCode}', tag: 'WaitingRoom');
        // Cancel our subscription - GameController will handle messages now
        _messageSubscription?.cancel();
        _messageSubscription = null;
        context.push(AppRoutes.chess);
      }
    });
  }

  Future<void> _connectToRoom() async {
    AppLogger.info('Connecting to room: ${widget.roomCode}', tag: 'WaitingRoom');
    setState(() {
      _isConnecting = true;
      _isWaiting = true;
    });

    try {
      await _roomHandler.connectToRoom(widget.roomCode);
      AppLogger.info('Connected to room successfully', tag: 'WaitingRoom');
      
      setState(() {
        _isConnecting = false;
      });
      
      _messageSubscription = _roomHandler.messageStream.listen((message) {
        final type = message['type'] as String?;
        AppLogger.debug('Received message type: $type', tag: 'WaitingRoom');
        
        // Once we navigate to chess screen, stop processing messages here
        // GameController will handle all game-related messages
        if (_hasNavigated) {
          AppLogger.debug('WaitingRoom: Ignoring message (already navigated): $type', tag: 'WaitingRoom');
          return;
        }
        
        if (type == 'room_joined') {
          // Room joined successfully - set player side from server
          // player_side is at the top level of the message, not in 'data'
          final playerSideStr = message['player_side'] as String?;
          if (playerSideStr != null) {
            // Convert backend side ("light"/"dark") to Flutter Side enum
            final playerSide = playerSideStr == 'light' ? Side.light : Side.dark;
            PlayerSideMediator.changePlayerSide(playerSide);
            AppLogger.info('Player side set to: ${playerSide.name} (from server)', tag: 'WaitingRoom');
          } else {
            AppLogger.warning('No player_side in room_joined message', tag: 'WaitingRoom');
          }
          AppLogger.info('Room joined successfully', tag: 'WaitingRoom');
          
          // Check if room is already full (in_progress) - if so, navigate immediately
          final roomStatus = GameModesMediator.currentRoomStatus;
          if (roomStatus == 'in_progress') {
            AppLogger.info('Room is already full (in_progress), navigating to game immediately', tag: 'WaitingRoom');
            _navigateToGame();
            return;
          }
          
          setState(() {
            _isWaiting = true;
            _isConnecting = false;
          });
          
          // Start heartbeat timer after successfully joining room
          _startHeartbeatTimer();
        } else if (type == 'player_joined') {
          // Another player joined, start the game
          AppLogger.info('Opponent joined, starting game', tag: 'WaitingRoom');
          
          // Extract opponent info if available
          final opponentInfo = message['opponent'] as Map<String, dynamic>?;
          if (opponentInfo != null) {
            GameModesMediator.setOpponentInfo(opponentInfo);
            AppLogger.info('Stored opponent info: ${opponentInfo['username']}, avatar: ${opponentInfo['avatar_icon']}', tag: 'WaitingRoom');
          }
          
          setState(() {
            _isWaiting = false;
            _isConnecting = false;
          });
          _navigateToGame(opponentInfo);
        } else if (type == 'error') {
          final errorMsg = message['message'] as String? ?? 'An error occurred';
          AppLogger.error('Error in waiting room: $errorMsg', tag: 'WaitingRoom');
          setState(() {
            _errorMessage = errorMsg;
            _isWaiting = false;
            _isConnecting = false;
          });
        }
      });
    } catch (e) {
      AppLogger.error('Failed to connect to room: $e', tag: 'WaitingRoom', error: e);
      setState(() {
        _errorMessage = 'Failed to connect: $e';
        _isWaiting = false;
        _isConnecting = false;
      });
    }
  }

  void _startHeartbeatTimer() {
    // Cancel existing timer if any
    _heartbeatTimer?.cancel();
    
    // Start periodic heartbeat every 15 seconds
    _heartbeatTimer = Timer.periodic(const Duration(seconds: 15), (timer) {
      if (!mounted || _hasNavigated) {
        timer.cancel();
        return;
      }
      
      // Send heartbeat to keep connection alive and verify user is still waiting
      _sendHeartbeat();
    });
  }
  
  void _sendHeartbeat() {
    if (!_roomHandler.isConnected || _hasNavigated) {
      return;
    }
    
    try {
      AppLogger.debug('Sending heartbeat to verify user is still waiting', tag: 'WaitingRoom');
      // Send heartbeat message via WebSocket
      // The backend will use this to verify the user is still active
      final heartbeatMessage = json.encode({
        'type': 'heartbeat',
        'data': {
          'room_code': widget.roomCode,
        },
      });
      
      // Access the WebSocket channel to send heartbeat
      // Note: We need to add a method to GameRoomHandler to send custom messages
      _roomHandler.sendHeartbeat(heartbeatMessage);
    } catch (e) {
      AppLogger.warning('Failed to send heartbeat: $e', tag: 'WaitingRoom');
    }
  }

  @override
  void dispose() {
    AppLogger.info('Disposing WaitingRoomScreen', tag: 'WaitingRoom');
    _heartbeatTimer?.cancel();
    _messageSubscription?.cancel();
    // Only dispose handler if it's not being reused by GameController
    // If handler is shared, GameController will dispose it
    if (GameModesMediator.sharedRoomHandler != _roomHandler) {
      AppLogger.info('Disposing room handler (not shared)', tag: 'WaitingRoom');
      _roomHandler.dispose();
    } else {
      AppLogger.info('Keeping room handler for reuse (it is shared)', tag: 'WaitingRoom');
    }
    super.dispose();
  }

  void _handleCancel() {
    AppLogger.info('User cancelled waiting room', tag: 'WaitingRoom');
    _heartbeatTimer?.cancel();
    _messageSubscription?.cancel();
    // Close WebSocket connection - this will trigger backend cleanup
    _roomHandler.dispose();
    if (mounted) {
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Palette.background,
              Palette.backgroundSecondary,
              Palette.backgroundTertiary,
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (_isConnecting) ...[
                    Container(
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: Palette.backgroundTertiary,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: Palette.glassBorder,
                          width: 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          const CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(Palette.accent),
                          ),
                          const SizedBox(height: 32),
                          Text(
                            'Connecting to room...',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: Palette.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Please wait',
                            style: TextStyle(
                              fontSize: 14,
                              color: Palette.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ] else if (_isWaiting) ...[
                    Container(
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
                            color: Palette.accent.withOpacity(0.1),
                            blurRadius: 20,
                            spreadRadius: 0,
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Palette.accent.withOpacity(0.1),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Palette.accent.withOpacity(0.3),
                                width: 2,
                              ),
                            ),
                            child: const CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(Palette.accent),
                            ),
                          ),
                          const SizedBox(height: 32),
                          Text(
                            'Waiting for opponent...',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Palette.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'We are searching for an opponent for you...',
                            style: TextStyle(
                              fontSize: 16,
                              color: Palette.textSecondary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 32),
                          // Cancel button
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _handleCancel,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Palette.backgroundTertiary,
                                foregroundColor: Palette.textPrimary,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  side: BorderSide(
                                    color: Palette.glassBorder,
                                    width: 1,
                                  ),
                                ),
                              ),
                              child: const Text(
                                'Cancel',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ] else if (_errorMessage != null) ...[
                    Container(
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: Palette.backgroundTertiary,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: Palette.error.withOpacity(0.5),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Palette.error.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.error_outline,
                              size: 48,
                              color: Palette.error,
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            'Connection Error',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Palette.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _errorMessage!,
                            style: TextStyle(
                              fontSize: 16,
                              color: Palette.textSecondary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 32),
                          ElevatedButton(
                            onPressed: () => context.pop(),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Palette.error,
                              foregroundColor: Palette.textPrimary,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 32,
                                vertical: 16,
                              ),
                            ),
                            child: const Text('Go Back'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

