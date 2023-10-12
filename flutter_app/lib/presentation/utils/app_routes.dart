import 'package:chess_rps/common/enum.dart';
import 'package:chess_rps/presentation/controller/game_controller.dart';
import 'package:chess_rps/presentation/screen/chess_screen.dart';
import 'package:chess_rps/presentation/screen/mode_selector.dart';
import 'package:chess_rps/presentation/mediator/player_side_mediator.dart';
import 'package:flutter/cupertino.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final appRoutes = <String, Widget Function(BuildContext)>{
  ModeSelector.routeName: (context) => const ModeSelector(),
  ChessScreen.routeName: (context) {
    Side playerSide = Side.light;

    final args = ModalRoute.of(context)?.settings.arguments;
    if (args != null) {
      playerSide = args as Side;
      PlayerSideMediator.changePlayerSide(playerSide);
    }

    return ProviderScope(
      overrides: [gameControllerProvider.overrideWith(() => GameController())],
      child: const ChessScreen(),
    );
  },
};
