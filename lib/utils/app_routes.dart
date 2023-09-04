import 'package:chess_rps/screen/chess_screen.dart';
import 'package:chess_rps/screen/mode_selector.dart';
import 'package:flutter/cupertino.dart';

final appRoutes = <String, Widget Function(BuildContext)>{
  ModeSelector.routeName: (context) => const ModeSelector(),
  ChessScreen.routeName: (context) => const ChessScreen(),
};
