import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:stockfish/stockfish.dart';

class StockfishHandler {
  late final Stockfish _engine;
  late StreamSubscription _outputListener;

  Stream<String> get outputStream => _engine.stdout;

  void initEngine() {
    _engine = Stockfish();
  }

  void disposeEngine() {
    _outputListener.cancel();

    _engine.stdin = 'quit';
    _engine.dispose();
  }

  String getState() => _engine.state.value.name;
  ValueListenable<StockfishState> get stateListenable => _engine.state;

  void registerOutputCallback() {}

  void setCommand(String uniCommand) {
    _engine.stdin = uniCommand;
  }
}
