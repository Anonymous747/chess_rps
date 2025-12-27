import 'package:chess_rps/common/enum.dart';
import 'package:chess_rps/common/logger.dart';

import 'package:chess_rps/data/service/socket/game_room_handler.dart';

/// Define game modes, which includes [GameMode] and [OpponentMode]
///
class GameModesMediator {
  static GameMode _gameMode = GameMode.classical;
  static OpponentMode _opponentMode = OpponentMode.socket;
  static String? _currentRoomCode;
  static String? _currentRoomStatus; // Store room status (waiting, in_progress)
  static GameRoomHandler? _sharedRoomHandler; // Shared handler to reuse connections
  static Map<String, dynamic>? _opponentInfo; // Store opponent info (user_id, username, avatar_icon)
  static int _aiDifficulty = 15; // Default to medium difficulty (skill level 15)

  static GameMode get gameMode => _gameMode;
  static OpponentMode get opponentMode => _opponentMode;
  static String? get currentRoomCode => _currentRoomCode;
  static String? get currentRoomStatus => _currentRoomStatus;
  static GameRoomHandler? get sharedRoomHandler => _sharedRoomHandler;
  static int get aiDifficulty => _aiDifficulty;

  static void changeGameMode(GameMode mode) {
    AppLogger.info('Changing game mode from $_gameMode to $mode', tag: 'GameModesMediator');
    _gameMode = mode;
  }

  static void changeOpponentMode(OpponentMode mode) {
    AppLogger.info('Changing opponent mode from $_opponentMode to $mode', tag: 'GameModesMediator');
    _opponentMode = mode;
  }
  
  static void setRoomCode(String? roomCode) {
    AppLogger.info('Setting room code: $roomCode', tag: 'GameModesMediator');
    _currentRoomCode = roomCode;
  }
  
  static void setRoomStatus(String? roomStatus) {
    AppLogger.info('Setting room status: $roomStatus', tag: 'GameModesMediator');
    _currentRoomStatus = roomStatus;
  }
  
  /// Set shared room handler (to reuse connection from WaitingRoomScreen)
  static void setSharedRoomHandler(GameRoomHandler? handler) {
    AppLogger.info('Setting shared room handler: ${handler != null ? "provided" : "null"}', tag: 'GameModesMediator');
    _sharedRoomHandler = handler;
  }
  
  /// Clear shared room handler (call when done with game)
  static void clearSharedRoomHandler() {
    AppLogger.info('Clearing shared room handler', tag: 'GameModesMediator');
    _sharedRoomHandler = null;
  }

  static Map<String, dynamic>? get opponentInfo => _opponentInfo;

  static void setOpponentInfo(Map<String, dynamic>? info) {
    _opponentInfo = info;
  }

  static void setAIDifficulty(int skillLevel) {
    AppLogger.info('Setting AI difficulty (skill level): $skillLevel', tag: 'GameModesMediator');
    _aiDifficulty = skillLevel.clamp(0, 20); // Clamp between 0 and 20
  }

  static void makeByDefault() {
    AppLogger.info('Setting default game modes: classical, ai', tag: 'GameModesMediator');
    _gameMode = GameMode.classical;
    _opponentMode = OpponentMode.ai;
    _currentRoomCode = null;
    _currentRoomStatus = null;
    _sharedRoomHandler = null;
    _opponentInfo = null;
    _aiDifficulty = 15; // Reset to medium difficulty
  }
}
