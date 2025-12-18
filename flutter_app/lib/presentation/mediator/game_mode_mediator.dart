import 'package:chess_rps/common/enum.dart';
import 'package:chess_rps/common/logger.dart';

/// Define game modes, which includes [GameMode] and [OpponentMode]
///
class GameModesMediator {
  static GameMode _gameMode = GameMode.classical;
  static OpponentMode _opponentMode = OpponentMode.socket;

  static GameMode get gameMode => _gameMode;
  static OpponentMode get opponentMode => _opponentMode;

  static void changeGameMode(GameMode mode) {
    AppLogger.info('Changing game mode from $_gameMode to $mode', tag: 'GameModesMediator');
    _gameMode = mode;
  }

  static void changeOpponentMode(OpponentMode mode) {
    AppLogger.info('Changing opponent mode from $_opponentMode to $mode', tag: 'GameModesMediator');
    _opponentMode = mode;
  }

  static void makeByDefault() {
    AppLogger.info('Setting default game modes: classical, ai', tag: 'GameModesMediator');
    _gameMode = GameMode.classical;
    _opponentMode = OpponentMode.ai;
  }
}
