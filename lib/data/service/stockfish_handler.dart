import 'package:chess_rps/domain/service/ai_handler.dart';
import 'package:stockfish/stockfish.dart';

class StockfishHandler implements AIHandler {
  late final Stockfish _engine;

  @override
  void initEngine() {
    _engine = Stockfish();
  }

  @override
  void disposeEngine() {
    _engine.stdin = 'quite';
    _engine.dispose();
  }

  @override
  String getState() => _engine.state.value.name;

  @override
  void registerOutputCallback() {
    // TODO: implement registerOutputCallback
  }

  @override
  void setCommand(String uniCommand) {
    // TODO: implement setCommand
  }
}
