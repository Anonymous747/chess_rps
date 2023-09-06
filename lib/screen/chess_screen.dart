import 'package:chess_rps/controller/game_controller.dart';
import 'package:chess_rps/widget/board_widget.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class ChessScreen extends HookConsumerWidget {
  static const routeName = 'chess';

  const ChessScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final board = ref.read(gameControllerProvider);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const Expanded(
              child: Center(
                child: Text('Top field'),
              ),
            ),
            BoardWidget(board: board),
            const Expanded(
                child: Center(
              child: Text('Bottom field'),
            ))
          ],
        ),
      ),
    );
  }
}
