import 'package:chess_rps/widget/board_widget.dart';
import 'package:flutter/material.dart';

class ChessScreen extends StatelessWidget {
  static const routeName = 'chess';

  const ChessScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: Text('Top field'),
              ),
            ),
            BoardWidget(),
            Expanded(
                child: Center(
              child: Text('Bottom field'),
            ))
          ],
        ),
      ),
    );
  }
}
