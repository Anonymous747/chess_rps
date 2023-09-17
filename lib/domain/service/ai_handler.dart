import 'package:chess_rps/data/service/stockfish_handler.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'ai_handler.g.dart';

@riverpod
AIHandler createAIHandler(CreateAIHandlerRef ref) {
  return StockfishHandler();
}

abstract class AIHandler {
  void initEngine();
  void disposeEngine();

  String getState();
  void setCommand(String uniCommand);

  void registerOutputCallback();
}
