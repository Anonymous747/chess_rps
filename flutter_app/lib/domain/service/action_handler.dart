import 'package:chess_rps/common/enum.dart';
import 'package:chess_rps/common/logger.dart';
import 'package:chess_rps/data/service/game/ai_action_handler.dart';
import 'package:chess_rps/data/service/socket/socket_action_handler.dart';
import 'package:chess_rps/presentation/mediator/game_mode_mediator.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:riverpod/riverpod.dart';
import 'package:stockfish_interpreter/stockfish/stockfish_interpreter.dart';

part 'action_handler.g.dart';

@riverpod
ActionHandler actionHandler(Ref ref) {
  final opponentMode = GameModesMediator.opponentMode;
  AppLogger.info('Creating ActionHandler. Opponent mode: $opponentMode', tag: 'ActionHandlerProvider');
  
  ActionHandler handler;
  switch (opponentMode) {
    case OpponentMode.ai:
      AppLogger.info('Creating AIActionHandler with Stockfish interpreter', tag: 'ActionHandlerProvider');
      handler = AIActionHandler(
          StockfishInterpreter(parameters: {}, isLoggerSwitchOn: true));
      break;
    case OpponentMode.socket:
      AppLogger.info('Creating SocketActionHandler for online play', tag: 'ActionHandlerProvider');
      handler = SocketActionHandler();
      break;
  }
  
  // Keep the provider alive to prevent disposal during Stockfish initialization
  ref.keepAlive();
  
  // Ensure handler is disposed when provider is disposed
  ref.onDispose(() {
    AppLogger.info('Disposing ActionHandler', tag: 'ActionHandlerProvider');
    handler.dispose();
  });
  
  return handler;
}

/// Define opponents behaviour during a game
///
abstract class ActionHandler {
  Future<String?> getOpponentsMove();
  Future<void> makeMove(String action);
  Future<void> visualizeBoard() async {}
  Future<void> dispose();
}
