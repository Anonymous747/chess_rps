import 'dart:async';

import 'package:chess_rps/domain/service/action_handler.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

const String _socketUrl = 'ws://10.0.2.2:8000/game/ws/112';
const String _opponentMoveSign = 'Opponent move ';

class SocketActionHandler extends ActionHandler {
  late final WebSocketChannel _channel;
  set sink(String action) => _channel.sink.add(action);

  final StreamController _controller = StreamController.broadcast();
  final List<StreamSubscription> _subs = <StreamSubscription>[];

  SocketActionHandler() {
    _channel = IOWebSocketChannel.connect(Uri.parse(_socketUrl));

    _subs.add(_channel.stream.listen((event) {
      _controller.add(event);
    }));
  }

  /// This method works under the assumption that when the opponent makes a move,
  /// this message will include "Opponent move".
  ///
  @override
  Future<String?> getOpponentsMove() async {
    String action = await _controller.stream.firstWhere((action) {
      return action.toString().contains(_opponentMoveSign);
    });

    return action.split(" ").last;
  }

  @override
  Future<void> makeMove(String action) async {
    sink = action;
  }

  @override
  Future<void> dispose() async {
    for (final sub in _subs) {
      sub.cancel();
    }

    await _channel.sink.close();
  }
}
