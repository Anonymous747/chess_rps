import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:stockfish/stockfish.dart';

class StockfishHandler {
  late final Stockfish _engine;

  Stream<String> get outputStream => _engine.stdout;

  void initEngine() {
    _engine = Stockfish();
  }

  void disposeEngine() {
    _engine.dispose();
  }

  String getState() => _engine.state.value.name;
  ValueListenable<StockfishState> get stateListenable => _engine.state;

  void setCommand(String uniCommand) {
    _engine.stdin = uniCommand;
  }
}
