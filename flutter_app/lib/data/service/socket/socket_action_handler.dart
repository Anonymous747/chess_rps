import 'dart:async';

import 'package:chess_rps/common/logger.dart';
import 'package:chess_rps/common/rps_choice.dart';
import 'package:chess_rps/data/service/socket/game_room_handler.dart';
import 'package:chess_rps/domain/service/action_handler.dart';

import 'package:chess_rps/presentation/mediator/game_mode_mediator.dart';

class SocketActionHandler extends ActionHandler {
  late final GameRoomHandler _roomHandler;
  bool _ownsHandler = false; // Track if we own the handler or if it's shared

  SocketActionHandler() {
    AppLogger.info('Creating SocketActionHandler', tag: 'SocketActionHandler');
    
    // Try to reuse shared handler from WaitingRoomScreen
    final sharedHandler = GameModesMediator.sharedRoomHandler;
    if (sharedHandler != null) {
      AppLogger.info('Reusing shared room handler from WaitingRoomScreen', tag: 'SocketActionHandler');
      _roomHandler = sharedHandler;
      _ownsHandler = false; // Don't dispose shared handler
    } else {
      AppLogger.info('Creating new room handler (no shared handler available)', tag: 'SocketActionHandler');
      _roomHandler = GameRoomHandler();
      _ownsHandler = true; // We own this handler, dispose it
    }
  }

  Future<void> connectToRoom(String roomCode) async {
    AppLogger.info('Connecting to room via SocketActionHandler: $roomCode', tag: 'SocketActionHandler');
    // Check if already connected
    if (_roomHandler.isConnected && _roomHandler.roomCode == roomCode) {
      AppLogger.info('Already connected to room $roomCode, skipping reconnection', tag: 'SocketActionHandler');
      return;
    }
    await _roomHandler.connectToRoom(roomCode);
  }

  Future<void> sendRpsChoice(RpsChoice choice) async {
    AppLogger.info('Sending RPS choice via SocketActionHandler: ${choice.name}', tag: 'SocketActionHandler');
    await _roomHandler.sendRpsChoice(choice);
  }

  /// This method works under the assumption that when the opponent makes a move,
  /// the message will be of type "move".
  ///
  @override
  Future<String?> getOpponentsMove() async {
    AppLogger.info('Waiting for opponent move from socket', tag: 'SocketActionHandler');
    final message = await _roomHandler.messageStream.firstWhere((message) {
      return message['type'] == 'move' &&
          message['data'] != null &&
          message['data']['move_notation'] != null;
    });

    final move = message['data']['move_notation'] as String?;
    AppLogger.info('Received opponent move: $move', tag: 'SocketActionHandler');
    return move;
  }

  @override
  Future<void> makeMove(String action) async {
    AppLogger.info('Sending move via SocketActionHandler: $action', tag: 'SocketActionHandler');
    await _roomHandler.sendMove(action);
  }

  Stream<Map<String, dynamic>> get messageStream => _roomHandler.messageStream;

  @override
  Future<void> dispose() async {
    AppLogger.info('Disposing SocketActionHandler (owns handler: $_ownsHandler)', tag: 'SocketActionHandler');
    // Only dispose handler if we own it (not shared)
    if (_ownsHandler) {
      await _roomHandler.dispose();
      AppLogger.info('Disposed owned room handler', tag: 'SocketActionHandler');
    } else {
      AppLogger.info('Skipping disposal of shared room handler', tag: 'SocketActionHandler');
      // Clear shared reference
      if (GameModesMediator.sharedRoomHandler == _roomHandler) {
        GameModesMediator.clearSharedRoomHandler();
      }
    }
  }
}
