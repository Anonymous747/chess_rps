import 'package:chess_rps/common/assets.dart';
import 'package:flutter/material.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testGoldens('Check image load', (tester) async {
    await tester.runAsync(() async {
      final child = MaterialApp(
        home: Scaffold(
          body: RepaintBoundary(
            child: Container(
              width: 200.0,
              height: 200.0,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(
                    Assets.blackBishop,
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pumpWidget(child);

      Element element = tester.element(find.byType(DecoratedBox));
      DecoratedBox widget = element.widget as DecoratedBox;
      BoxDecoration decoration = widget.decoration as BoxDecoration;
      await precacheImage(decoration.image!.image, element);

      await tester.pumpAndSettle();
    });

    await expectLater(find.byType(MaterialApp),
        matchesGoldenFile('snapshots/chess_screen_board.png'));
  });

  // testGoldens('Chess screen board golden test', (tester) async {
  //   await tester.pumpWidgetBuilder(
  //     MaterialApp(
  //         home: ProviderScope(overrides: [
  //       gameControllerProvider.overrideWith(() => GameControllerMock()),
  //     ], child: const ChessScreen())),
  //     surfaceSize: const Size(720, 1020),
  //   );
  //
  // for (final assetName in Assets.figures) {
  //   precacheImage(AssetImage(assetName), element);
  // }
  //   await expectLater(find.byType(ChessScreen),
  //       matchesGoldenFile('snapshots/chess_screen_with_figures.png'));
  // });
}
