import 'package:chess_rps/common/enum.dart';

/// Define the mode of a game
///
class GameModeMediator {
  static GameMode _gameMode = GameMode.classicalAi;

  static GameMode get gameMode => _gameMode;

  void changeGameMode(GameMode mode) {
    _gameMode = mode;
  }

  void makeByDefault() {
    _gameMode = GameMode.classicalAi;
  }
}
