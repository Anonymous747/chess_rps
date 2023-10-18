import 'package:chess_rps/common/enum.dart';
import 'package:chess_rps/data/service/game/ai_action_handler.dart';
import 'package:chess_rps/data/service/socket/socket_action_handler.dart';
import 'package:chess_rps/presentation/mediator/game_mode_mediator.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:stockfish_interpreter/stockfish/stockfish_interpreter.dart';

part 'action_handler.g.dart';

@riverpod
ActionHandler actionHandler(ActionHandlerRef ref) {
  switch (GameModesMediator.opponentMode) {
    case OpponentMode.ai:
      return AIActionHandler(
          StockfishInterpreter(parameters: {}, isLoggerSwitchOn: true));
    case OpponentMode.socket:
      return SocketActionHandler();
  }
}

/// Define opponents behaviour during a game
///
abstract class ActionHandler {
  Future<String?> getOpponentsMove();
  Future<void> makeMove(String action);
  Future<void> visualizeBoard() async {}
  Future<void> dispose();
}
