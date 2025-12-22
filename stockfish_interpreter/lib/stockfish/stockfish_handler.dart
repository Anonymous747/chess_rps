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
    try {
      final state = _engine.state.value;
      
      // Only dispose if engine is ready
      // If engine is starting or already disposed, skip disposal
      // Stockfish will be cleaned up automatically if not ready
      if (state == StockfishState.ready) {
        _engine.dispose();
      } else if (state == StockfishState.starting) {
        // Engine is still starting - try to dispose after a short delay
        // If it's not ready by then, it will be cleaned up automatically
        Future.delayed(const Duration(milliseconds: 500), () {
          try {
            if (_engine.state.value == StockfishState.ready) {
              _engine.dispose();
            }
          } catch (e) {
            // Ignore errors - engine might not be ready or already disposed
          }
        });
      }
      // If already disposed, nothing to do
    } catch (e) {
      // Ignore errors during disposal - engine might already be disposed
      // or in an invalid state that doesn't allow disposal
      // Stockfish will be cleaned up automatically by the system
    }
  }

  String getState() => _engine.state.value.name;
  ValueListenable<StockfishState> get stateListenable => _engine.state;

  void setCommand(String uniCommand) {
    _engine.stdin = uniCommand;
  }
}
