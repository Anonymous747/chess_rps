import 'dart:async';
import 'dart:convert';
import 'package:chess_rps/common/endpoint.dart';
import 'package:chess_rps/common/logger.dart';
import 'package:chess_rps/common/rps_choice.dart';
import 'package:dio/dio.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class GameRoomHandler {
  WebSocketChannel? _channel;
  final StreamController<Map<String, dynamic>> _messageController =
      StreamController<Map<String, dynamic>>.broadcast();
  final List<StreamSubscription> _subs = <StreamSubscription>[];

  String? _roomCode;
  bool _isConnected = false;

  bool get isConnected => _isConnected;
  String? get roomCode => _roomCode;

  Stream<Map<String, dynamic>> get messageStream => _messageController.stream;

  Future<void> connectToRoom(String roomCode) async {
    AppLogger.info('Connecting to room: $roomCode', tag: 'GameRoomHandler');
    _roomCode = roomCode;
    final url = 'ws://${Endpoint.opponentSocket}/$roomCode';
    
    try {
      AppLogger.debug('WebSocket URL: $url', tag: 'GameRoomHandler');
      _channel = WebSocketChannel.connect(Uri.parse(url));

      _subs.add(_channel!.stream.listen(
        (event) {
          try {
            final message = json.decode(event.toString()) as Map<String, dynamic>;
            AppLogger.debug('Received message: ${message['type']}', tag: 'GameRoomHandler');
            _messageController.add(message);
          } catch (e) {
            AppLogger.warning('Failed to parse message: $e', tag: 'GameRoomHandler');
            // Handle non-JSON messages
            _messageController.add({
              'type': 'raw',
              'data': event.toString(),
            });
          }
        },
        onError: (error) {
          AppLogger.error('WebSocket error: $error', tag: 'GameRoomHandler');
          _messageController.add({
            'type': 'error',
            'data': {'message': error.toString()},
          });
        },
        onDone: () {
          AppLogger.info('WebSocket connection closed', tag: 'GameRoomHandler');
          _isConnected = false;
          _messageController.add({
            'type': 'disconnected',
            'data': {},
          });
        },
      ));

      _isConnected = true;
      AppLogger.info('Successfully connected to room: $roomCode', tag: 'GameRoomHandler');
    } catch (e) {
      AppLogger.error('Failed to connect to room: $e', tag: 'GameRoomHandler', error: e);
      rethrow;
    }
  }

  Future<String> createRoom(String gameMode) async {
    AppLogger.info('Creating room with game mode: $gameMode', tag: 'GameRoomHandler');
    try {
      final dio = Dio();
      AppLogger.debug('Sending POST request to: ${Endpoint.createRoom}', tag: 'GameRoomHandler');
      final response = await dio.post(
        Endpoint.createRoom,
        data: {'game_mode': gameMode},
      );
      
      if (response.statusCode == 201) {
        final roomData = response.data as Map<String, dynamic>;
        final roomCode = roomData['room_code'] as String;
        AppLogger.info('Room created successfully: $roomCode', tag: 'GameRoomHandler');
        return roomCode;
      } else {
        AppLogger.error('Failed to create room: ${response.statusCode}', tag: 'GameRoomHandler');
        throw Exception('Failed to create room: ${response.statusCode}');
      }
    } catch (e) {
      // Fallback to random code if HTTP fails
      AppLogger.warning('Error creating room via HTTP, using fallback: $e', tag: 'GameRoomHandler', error: e);
      final roomCode = DateTime.now().millisecondsSinceEpoch.toString().substring(7);
      AppLogger.info('Using fallback room code: $roomCode', tag: 'GameRoomHandler');
      return roomCode;
    }
  }

  Future<void> sendMove(String moveNotation) async {
    if (!_isConnected || _channel == null) {
      AppLogger.warning('Cannot send move: not connected', tag: 'GameRoomHandler');
      return;
    }

    AppLogger.info('Sending move: $moveNotation', tag: 'GameRoomHandler');
    final message = {
      'type': 'move',
      'data': {
        'move_notation': moveNotation,
      },
    };

    try {
      _channel!.sink.add(json.encode(message));
      AppLogger.debug('Move sent successfully', tag: 'GameRoomHandler');
    } catch (e) {
      AppLogger.error('Failed to send move: $e', tag: 'GameRoomHandler', error: e);
      rethrow;
    }
  }

  Future<void> sendRpsChoice(RpsChoice choice) async {
    if (!_isConnected || _channel == null) {
      AppLogger.warning('Cannot send RPS choice: not connected', tag: 'GameRoomHandler');
      return;
    }

    AppLogger.info('Sending RPS choice: ${choice.name}', tag: 'GameRoomHandler');
    final message = {
      'type': 'rps_choice',
      'data': {
        'choice': choice.name,
      },
    };

    try {
      _channel!.sink.add(json.encode(message));
      AppLogger.debug('RPS choice sent successfully', tag: 'GameRoomHandler');
    } catch (e) {
      AppLogger.error('Failed to send RPS choice: $e', tag: 'GameRoomHandler', error: e);
      rethrow;
    }
  }

  Future<void> dispose() async {
    AppLogger.info('Disposing GameRoomHandler', tag: 'GameRoomHandler');
    for (final sub in _subs) {
      await sub.cancel();
    }
    if (_channel != null) {
      await _channel!.sink.close();
    }
    await _messageController.close();
    _isConnected = false;
    _channel = null;
    AppLogger.debug('GameRoomHandler disposed', tag: 'GameRoomHandler');
  }
}

