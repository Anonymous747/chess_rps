import 'package:chess_rps/common/assets.dart';
import 'package:chess_rps/presentation/screen/chess_screen.dart';
import 'package:flutter/material.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../mocks/widget.dart';

void main() {
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
        matchesGoldenFile('snapshots/image_load_check.png'));
  });

  group('Chess screen', () {
    testGoldens('Board golden test', (tester) async {
      TestWidgetsFlutterBinding.ensureInitialized();

      await tester.binding.setSurfaceSize(const Size(820, 1230));

      await tester.runAsync(() async {
        await tester.pumpWidget(const TestWrapper(child: ChessScreen()));

        final elements = find.byKey(const ValueKey('figureKey')).evaluate();

        for (final element in elements) {
          final imageContainer = element.widget as Container;
          final decoration = imageContainer.decoration as BoxDecoration;

          // await precacheImage(decoration.image!.image, element);
        }
        await tester.pumpAndSettle();
      });

      await expectLater(find.byType(MaterialApp),
          matchesGoldenFile('snapshots/chess_screen_board.png'));
    });
  });
}
