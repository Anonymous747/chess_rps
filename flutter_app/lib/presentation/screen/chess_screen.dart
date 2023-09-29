import 'package:chess_rps/presentation/controller/game_controller.dart';
import 'package:chess_rps/presentation/widget/board_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class ChessScreen extends HookConsumerWidget {
  static const routeName = 'chess';

  const ChessScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = ref.read(gameControllerProvider.notifier);
    final board =
        ref.read(gameControllerProvider.select((state) => state.board));
    final controller = useTextEditingController();

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: BackButton(onPressed: () {
                Navigator.pop(context);
                provider.dispose();
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
                  TextField(
                    controller: controller,
                  ),
                  MaterialButton(
                      child: Text('Press me'),
                      onPressed: () async {
                        await provider.executeCommand(controller.text);
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
