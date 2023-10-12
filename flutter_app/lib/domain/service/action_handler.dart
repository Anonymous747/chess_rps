import 'package:chess_rps/data/service/ai_action_handler.dart';
import 'package:chess_rps/data/service/socket_action_handler.dart';
import 'package:chess_rps/presentation/mediator/game_mode_mediator.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:stockfish_interpreter/stockfish/stockfish_interpreter.dart';

part 'action_handler.g.dart';

@riverpod
ActionHandler actionHandler(ActionHandlerRef ref) {
  if (GameModeMediator.gameMode.isAIOpponent) {
    return AIActionHandler(
        StockfishInterpreter(parameters: {}, isLoggerSwitchOn: true));
  }

  return SocketActionHandler();
}

abstract class ActionHandler {
  Future<String?> getOpponentsMove();
  Future<void> makeMove(String action);
  Future<void> visualizeBoard();

  void dispose();
}
