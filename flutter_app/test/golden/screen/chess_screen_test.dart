import 'package:chess_rps/presentation/screen/chess_screen.dart';
import 'package:flutter/material.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

void main() {
  testGoldens('chess_screen_test', (tester) async {
    await tester.pumpWidgetBuilder(
      ProviderScope(child: ChessScreen()),
      surfaceSize: Size(720, 1024),
    );

    matchesGoldenFile('bla');
  });
}
