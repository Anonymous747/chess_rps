import 'package:chess_rps/domain/model/board.dart';
import 'package:chess_rps/presentation/controller/game_controller.dart';
import 'package:chess_rps/presentation/widget/board_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../mocks/controller.dart';

void main() {
  group('Board widget', () {
    late Board board;
    late GameControllerMock gameController;

    setUp(() {
      board = Board()..startGame();
      gameController = GameControllerMock();
    });

    testGoldens('general with precaching test', (tester) async {
      await tester.binding.setSurfaceSize(const Size(820, 800));

      await tester.runAsync(() async {
        await tester.pumpWidget(MaterialApp(
            home: ProviderScope(overrides: [
          gameControllerProvider.overrideWith(() => gameController)
        ], child: BoardWidget(board: board))));

        final elements = find.byKey(const ValueKey('figureKey')).evaluate();

        for (final element in elements) {
          final imageContainer = element.widget as Container;
          final decoration = imageContainer.decoration as BoxDecoration;

          await precacheImage(decoration.image!.image, element);
        }
        await tester.pumpAndSettle();
      });

      await expectLater(find.byType(BoardWidget),
          matchesGoldenFile('snapshots/board_widget_general.png'));
    });

    testGoldens('with board after move and black pressed test', (tester) async {
      await tester.pumpFrames(
          MaterialApp(
              home: ProviderScope(overrides: [
            gameControllerProvider.overrideWith(() => gameController)
          ], child: BoardWidget(board: board))),
          const Duration(seconds: 2));

      final to = board.getCellAt(4, 4);
      final from = board.getCellAt(6, 4);

      gameController.makeMove(to, from: from);

      final aimedBlack = board.getCellAt(1, 3);

      gameController.showAvailableActions(aimedBlack);
      await tester.pump(const Duration(milliseconds: 400));

      await expectLater(
          find.byType(BoardWidget),
          matchesGoldenFile(
              'snapshots/board_widget_after_move_and_press_black.png'));
    });
  });
}
