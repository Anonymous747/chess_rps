import 'package:chess_rps/common/enum.dart';

/// Help convenient look for player side
///
class PlayerSideMediator {
  static Side _playerSide = Side.light;
  static Side get playerSide => _playerSide;

  static void changePlayerSide(Side newSide) {
    _playerSide = newSide;
  }

  static void makeByDefault() {
    _playerSide = Side.light;
  }
}
