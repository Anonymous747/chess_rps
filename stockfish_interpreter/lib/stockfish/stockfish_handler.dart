import 'dart:async';

import 'package:stockfish/stockfish.dart';

class StockfishHandler {
  late final Stockfish _engine;
  late StreamSubscription _outputListener;

  List<List<String>> outputs = [];

  Stream<String> get outputStream => _engine.stdout;

  void initEngine() {
    _engine = Stockfish();
    _outputListener = _engine.stdout.listen((output) {
      // print('========= output = $output');
      // print('========= ${_engine.state.value}');
    });
  }

  void disposeEngine() {
    _outputListener.cancel();

    _engine.stdin = 'quit';
    _engine.dispose();
  }

  String getState() => _engine.state.value.name;

  void registerOutputCallback() {}

  void setCommand(String uniCommand) {
    print('========= inner command = $uniCommand');
    _engine.stdin = uniCommand;
  }
}
