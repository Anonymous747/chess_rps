import 'dart:async';

import 'package:chess_rps/common/logger.dart';
import 'package:chess_rps/common/rps_choice.dart';
import 'package:chess_rps/data/service/socket/game_room_handler.dart';
import 'package:chess_rps/domain/service/action_handler.dart';

class SocketActionHandler extends ActionHandler {
  late final GameRoomHandler _roomHandler;

  SocketActionHandler() {
    AppLogger.info('Creating SocketActionHandler', tag: 'SocketActionHandler');
    _roomHandler = GameRoomHandler();
  }

  Future<void> connectToRoom(String roomCode) async {
    AppLogger.info('Connecting to room via SocketActionHandler: $roomCode', tag: 'SocketActionHandler');
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
    AppLogger.info('Disposing SocketActionHandler', tag: 'SocketActionHandler');
    await _roomHandler.dispose();
  }
}
