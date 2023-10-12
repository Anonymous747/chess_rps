import 'package:chess_rps/common/enum.dart';

/// Define game modes, which includes [GameMode] and [OpponentMode]
///
class GameModesMediator {
  static GameMode _gameMode = GameMode.classical;
  static OpponentMode _opponentMode = OpponentMode.ai;

  static GameMode get gameMode => _gameMode;
  static OpponentMode get opponentMode => _opponentMode;

  void changeGameMode(GameMode mode) {
    _gameMode = mode;
  }

  void changeOpponentMode(OpponentMode mode) {
    _opponentMode = opponentMode;
  }

  void makeByDefault() {
    _gameMode = GameMode.classical;
    _opponentMode = OpponentMode.ai;
  }
}
