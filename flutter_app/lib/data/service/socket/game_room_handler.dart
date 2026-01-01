import 'dart:async';
import 'dart:convert';
import 'package:chess_rps/common/enum.dart';
import 'package:chess_rps/common/endpoint.dart';
import 'package:chess_rps/common/logger.dart';
import 'package:chess_rps/common/rps_choice.dart';
import 'package:chess_rps/data/service/dio_logger_interceptor.dart';
import 'package:chess_rps/presentation/mediator/game_mode_mediator.dart';
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
    // Endpoint.opponentSocket already includes wss:// protocol, just append room code
    final url = '${Endpoint.opponentSocket}/$roomCode';

    try {
      AppLogger.debug('WebSocket URL: $url', tag: 'GameRoomHandler');
      _channel = WebSocketChannel.connect(Uri.parse(url));

      _subs.add(_channel!.stream.listen(
        (event) {
          try {
            final message =
                json.decode(event.toString()) as Map<String, dynamic>;
            AppLogger.debug('Received message: ${message['type']}',
                tag: 'GameRoomHandler');
            _messageController.add(message);
          } catch (e) {
            AppLogger.warning('Failed to parse message: $e',
                tag: 'GameRoomHandler');
            // Handle non-JSON messages
            _messageController.add({
              'type': 'raw',
              'data': event.toString(),
            });
          }
        },
        onError: (error) {
          AppLogger.error('WebSocket error: $error', tag: 'GameRoomHandler');
          // Don't set _isConnected = false on error - connection might still be alive
          // Only add error message, don't close the stream controller
          _messageController.add({
            'type': 'error',
            'data': {'message': error.toString()},
          });
        },
        onDone: () {
          AppLogger.info('WebSocket connection closed (onDone)',
              tag: 'GameRoomHandler');
          _isConnected = false;
          // Only add disconnected message, don't close the stream controller
          // This allows other listeners to handle the disconnection gracefully
          if (!_messageController.isClosed) {
            _messageController.add({
              'type': 'disconnected',
              'data': {},
            });
          }
        },
      ));

      _isConnected = true;
      AppLogger.info('Successfully connected to room: $roomCode',
          tag: 'GameRoomHandler');
    } catch (e) {
      AppLogger.error('Failed to connect to room: $e',
          tag: 'GameRoomHandler', error: e);
      rethrow;
    }
  }

  Future<String> createRoom(String gameMode) async {
    AppLogger.info('Creating room with game mode: $gameMode',
        tag: 'GameRoomHandler');
    try {
      final dio = Dio()..interceptors.add(DioLoggerInterceptor());
      AppLogger.debug('Sending POST request to: ${Endpoint.createRoom}',
          tag: 'GameRoomHandler');
      final response = await dio.post(
        Endpoint.createRoom,
        data: {'game_mode': gameMode},
      );

      if (response.statusCode == 201) {
        final roomData = response.data as Map<String, dynamic>;
        final roomCode = roomData['room_code'] as String;
        AppLogger.info('Room created successfully: $roomCode',
            tag: 'GameRoomHandler');
        return roomCode;
      } else {
        AppLogger.error('Failed to create room: ${response.statusCode}',
            tag: 'GameRoomHandler');
        throw Exception('Failed to create room: ${response.statusCode}');
      }
    } catch (e) {
      // Fallback to random code if HTTP fails
      AppLogger.warning('Error creating room via HTTP, using fallback: $e',
          tag: 'GameRoomHandler', error: e);
      final roomCode =
          DateTime.now().millisecondsSinceEpoch.toString().substring(7);
      AppLogger.info('Using fallback room code: $roomCode',
          tag: 'GameRoomHandler');
      return roomCode;
    }
  }

  /// Find a match - checks for available rooms first (for logging), then joins/creates via matchmake
  /// The matchmake endpoint handles the actual atomic matching with proper locking
  Future<String> findMatch(String gameMode) async {
    AppLogger.info('Finding match with game mode: $gameMode',
        tag: 'GameRoomHandler');
    try {
      final dio = Dio()..interceptors.add(DioLoggerInterceptor());

      // STEP 1: Check for available rooms first (GET request - read-only check for logging/visibility)
      // This is informational only - the matchmake endpoint will do the actual atomic matching
      AppLogger.info('Step 1: Checking for available rooms (informational)...',
          tag: 'GameRoomHandler');
      AppLogger.debug(
          'Sending GET request to: ${Endpoint.checkAvailableRoom}?game_mode=$gameMode',
          tag: 'GameRoomHandler');

      bool foundAvailableRoom = false;
      try {
        final checkResponse = await dio.get(
          Endpoint.checkAvailableRoom,
          queryParameters: {'game_mode': gameMode},
        );

        if (checkResponse.statusCode == 200 && checkResponse.data != null) {
          final roomData = checkResponse.data as Map<String, dynamic>;
          final roomCode = roomData['room_code'] as String;
          final status = roomData['status'] as String?;
          AppLogger.info(
              '✅ Found available room (check): $roomCode, status: $status',
              tag: 'GameRoomHandler');
          foundAvailableRoom = true;
        } else {
          AppLogger.info(
              'No available room found in check (response: ${checkResponse.statusCode})',
              tag: 'GameRoomHandler');
        }
      } catch (e) {
        // If check fails or returns null, proceed to matchmake anyway
        AppLogger.info('No available room found in check (null/error): $e',
            tag: 'GameRoomHandler');
      }

      // STEP 2: Join existing room or create new one via matchmake
      // This endpoint uses SELECT FOR UPDATE with proper locking to atomically match users
      // It will find available rooms and reserve slots, or create new rooms if needed
      if (foundAvailableRoom) {
        AppLogger.info(
            'Step 2: Attempting to join available room via matchmake...',
            tag: 'GameRoomHandler');
      } else {
        AppLogger.info(
            'Step 2: No room found in check, attempting matchmake (will find or create)...',
            tag: 'GameRoomHandler');
      }

      AppLogger.debug('Sending POST request to: ${Endpoint.matchmakeRoom}',
          tag: 'GameRoomHandler');

      final response = await dio.post(
        Endpoint.matchmakeRoom,
        data: {'game_mode': gameMode},
      );

      if (response.statusCode == 200) {
        final roomData = response.data as Map<String, dynamic>;
        final roomCode = roomData['room_code'] as String;
        final status = roomData['status'] as String?;

        // Store room status in mediator for waiting room to check
        if (status != null) {
          GameModesMediator.setRoomStatus(status);
        }

        if (foundAvailableRoom && status == 'waiting') {
          AppLogger.info(
              '✅ Joined available room via matchmake: $roomCode, status: $status',
              tag: 'GameRoomHandler');
        } else if (status == 'in_progress') {
          AppLogger.info(
              '✅ Matched to room via matchmake: $roomCode, status: $status (room is full)',
              tag: 'GameRoomHandler');
        } else {
          AppLogger.info(
              '✅ Created new room via matchmake: $roomCode, status: $status',
              tag: 'GameRoomHandler');
        }
        return roomCode;
      } else {
        AppLogger.error('Failed to join/create match: ${response.statusCode}',
            tag: 'GameRoomHandler');
        throw Exception('Failed to join/create match: ${response.statusCode}');
      }
    } catch (e) {
      AppLogger.error('Error finding match: $e',
          tag: 'GameRoomHandler', error: e);
      rethrow;
    }
  }

  Future<void> sendMove(String moveNotation) async {
    if (!_isConnected || _channel == null) {
      AppLogger.warning('Cannot send move: not connected',
          tag: 'GameRoomHandler');
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
      AppLogger.error('Failed to send move: $e',
          tag: 'GameRoomHandler', error: e);
      rethrow;
    }
  }

  Future<void> sendRpsChoice(RpsChoice choice) async {
    if (!_isConnected || _channel == null) {
      AppLogger.warning('Cannot send RPS choice: not connected',
          tag: 'GameRoomHandler');
      return;
    }

    AppLogger.info('Sending RPS choice: ${choice.name}',
        tag: 'GameRoomHandler');
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
      AppLogger.error('Failed to send RPS choice: $e',
          tag: 'GameRoomHandler', error: e);
      rethrow;
    }
  }

  Future<void> sendSurrender() async {
    if (!_isConnected || _channel == null) {
      AppLogger.warning('Cannot send surrender: not connected',
          tag: 'GameRoomHandler');
      return;
    }

    AppLogger.info('Sending surrender message', tag: 'GameRoomHandler');
    final message = {
      'type': 'surrender',
      'data': {},
    };

    try {
      _channel!.sink.add(json.encode(message));
      AppLogger.debug('Surrender message sent successfully',
          tag: 'GameRoomHandler');
    } catch (e) {
      AppLogger.error('Failed to send surrender: $e',
          tag: 'GameRoomHandler', error: e);
      rethrow;
    }
  }

  Future<void> sendGameOver(Side winner, Side loser) async {
    if (!_isConnected || _channel == null) {
      AppLogger.warning('Cannot send game over: not connected',
          tag: 'GameRoomHandler');
      return;
    }

    AppLogger.info('Sending game over message: winner=${winner.name}, loser=${loser.name}', tag: 'GameRoomHandler');
    final message = {
      'type': 'game_over',
      'data': {
        'winner': winner.name, // 'light' or 'dark'
        'loser': loser.name,
      },
    };

    try {
      _channel!.sink.add(json.encode(message));
      AppLogger.debug('Game over message sent successfully',
          tag: 'GameRoomHandler');
    } catch (e) {
      AppLogger.error('Failed to send game over: $e',
          tag: 'GameRoomHandler', error: e);
      rethrow;
    }
  }

  /// Send heartbeat message to verify user is still waiting
  /// This is called every 15 seconds while waiting for an opponent
  void sendHeartbeat(String message) {
    if (!_isConnected || _channel == null) {
      return;
    }

    try {
      _channel!.sink.add(message);
      AppLogger.debug('Heartbeat sent successfully', tag: 'GameRoomHandler');
    } catch (e) {
      AppLogger.warning('Failed to send heartbeat: $e', tag: 'GameRoomHandler');
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
