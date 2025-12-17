import 'dart:async';
import 'package:chess_rps/common/logger.dart';
import 'package:chess_rps/common/palette.dart';
import 'package:chess_rps/data/service/socket/game_room_handler.dart';
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
  bool _isWaiting = true;
  bool _isConnecting = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    AppLogger.info('WaitingRoomScreen initialized for room: ${widget.roomCode}', tag: 'WaitingRoom');
    _connectToRoom();
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
        
        if (type == 'room_joined') {
          // Room joined successfully
          AppLogger.info('Room joined successfully', tag: 'WaitingRoom');
          setState(() {
            _isWaiting = true;
            _isConnecting = false;
          });
        } else if (type == 'player_joined') {
          // Another player joined, start the game
          AppLogger.info('Opponent joined, starting game', tag: 'WaitingRoom');
          setState(() {
            _isWaiting = false;
            _isConnecting = false;
          });
          // Navigate to chess screen after a short delay
          Future.delayed(const Duration(milliseconds: 500), () {
            if (mounted) {
              AppLogger.info('Navigating to chess screen', tag: 'WaitingRoom');
              context.push(AppRoutes.chess);
            }
          });
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

  @override
  void dispose() {
    AppLogger.info('Disposing WaitingRoomScreen', tag: 'WaitingRoom');
    _messageSubscription?.cancel();
    _roomHandler.dispose();
    super.dispose();
  }

  void _handleCancel() {
    AppLogger.info('User cancelled waiting room', tag: 'WaitingRoom');
    _messageSubscription?.cancel();
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
                          const SizedBox(height: 32),
                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: Palette.backgroundElevated,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: Palette.accent.withOpacity(0.3),
                                width: 2,
                              ),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  'Room Code',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Palette.textSecondary,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 1,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 24,
                                    vertical: 16,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Palette.background,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    widget.roomCode,
                                    style: TextStyle(
                                      fontSize: 36,
                                      fontWeight: FontWeight.bold,
                                      color: Palette.accent,
                                      letterSpacing: 6,
                                      fontFamily: 'monospace',
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.share_outlined,
                                      size: 16,
                                      color: Palette.textTertiary,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Share this code with your opponent',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Palette.textTertiary,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
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

