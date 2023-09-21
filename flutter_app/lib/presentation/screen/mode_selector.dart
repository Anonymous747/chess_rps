import 'package:chess_rps/presentation/screen/chess_screen.dart';
import 'package:chess_rps/presentation/utils/custom_router.dart';
import 'package:flutter/material.dart';

const _normalModeText = 'Normal Mode';
const _rpsModeText = 'RPS Mode';

class ModeSelector extends StatelessWidget {
  static const routeName = "modeSelector";

  const ModeSelector({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              child: const Text(_normalModeText),
              onPressed: () => pushNamed(ChessScreen.routeName),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              child: const Text(_rpsModeText),
              onPressed: () => pushNamed(ChessScreen.routeName),
            ),
          ],
        ),
      ),
    );
  }
}
