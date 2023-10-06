import 'package:chess_rps/presentation/controller/game_controller.dart';
import 'package:chess_rps/presentation/widget/board_widget.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class ChessScreen extends HookConsumerWidget {
  static const routeName = 'chess';

  const ChessScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = ref.read(gameControllerProvider.notifier);
    final board =
        ref.read(gameControllerProvider.select((state) => state.board));

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: BackButton(onPressed: () {
                provider.dispose();
                Navigator.pop(context);
              }),
            ),
            const Expanded(
              child: Center(
                child: Text('Top field'),
              ),
            ),
            BoardWidget(board: board),
            Expanded(
                child: Center(
              child: Column(
                children: [
                  MaterialButton(
                      child: const Text('Press me'),
                      onPressed: () async {
                        await provider.executeCommand();
                      }),
                ],
              ),
            ))
          ],
        ),
      ),
    );
  }
}
