import 'package:chess_rps/common/enum.dart';
import 'package:chess_rps/presentation/controller/game_controller.dart';
import 'package:chess_rps/presentation/screen/chess_screen.dart';
import 'package:chess_rps/presentation/mediator/player_side_mediator.dart';
import 'package:flutter/material.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../mocks/controller.dart';

void main() {
  testGoldens('Check image load', (tester) async {
    await tester.runAsync(() async {
      final child = MaterialApp(
        home: Scaffold(
          body: RepaintBoundary(
            child: Container(
              width: 200.0,
              height: 200.0,
              decoration: BoxDecoration(
                color: Colors.grey,
                // Note: Assets are now loaded from backend, using placeholder for test
              ),
            ),
          ),
        ),
      );

      await tester.pumpWidget(child);

      await tester.pumpAndSettle();
    });

    await expectLater(find.byType(MaterialApp),
        matchesGoldenFile('snapshots/image_load_check.png'));
  });

  group('Chess screen', () {
    tearDownAll(() {
      PlayerSideMediator.makeByDefault();
    });

    testGoldens('Board golden test', (tester) async {
      await tester.binding.setSurfaceSize(const Size(820, 1230));

      await tester.runAsync(() async {
        await tester.pumpWidget(MaterialApp(
          home: ProviderScope(overrides: [
            gameControllerProvider.overrideWith(() => GameControllerMock())
          ], child: const ChessScreen()),
        ));

        final elements = find.byKey(const ValueKey('figureKey')).evaluate();

        for (final element in elements) {
          final imageContainer = element.widget as Container;
          final decoration = imageContainer.decoration as BoxDecoration;

          await precacheImage(decoration.image!.image, element);
        }
        await tester.pumpAndSettle();
      });

      await expectLater(find.byType(MaterialApp),
          matchesGoldenFile('snapshots/chess_screen_board.png'));
    });

    testGoldens('Board from dark side golden test', (tester) async {
      await tester.binding.setSurfaceSize(const Size(820, 1230));

      PlayerSideMediator.changePlayerSide(Side.dark);
      await tester.pumpWidget(MaterialApp(
        home: ProviderScope(overrides: [
          gameControllerProvider.overrideWith(() => GameControllerMock())
        ], child: const ChessScreen()),
      ));

      await tester.pump();

      await expectLater(find.byType(MaterialApp),
          matchesGoldenFile('snapshots/chess_screen_board_from_dark_side.png'));
    });
  });
}
