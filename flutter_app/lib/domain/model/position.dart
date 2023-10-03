import 'dart:math';

import 'package:chess_rps/common/enum.dart';
import 'package:chess_rps/common/extension.dart';
import 'package:chess_rps/domain/model/board.dart';
import 'package:chess_rps/presentation/utils/player_side_mediator.dart';

class Position {
  final int row;
  final int col;

  const Position({required this.row, required this.col});

  int get magnitude => sqrt(col * col + row * row).toInt();
}

extension PositionExtension on Position {
  /// Position represented in algebraic notation
  ///
  String get algebraicPosition {
    return PlayerSideMediator.playerSide == Side.light
        ? "${boardLetters[col]}${row.reversed}"
        : "${boardLetters[col.reversed + 1]}$row";
  }
}

extension ToPositionExtension on String {
  Position convertToPosition() {
    assert(
        length == 2, "Position in algebraic notation should include 2 signs");

    final col = boardLetters.indexOf(this[0]);
    final row = int.parse(this[1]);

    final isLightSidePlayer = PlayerSideMediator.playerSide == Side.light;

    return Position(row: isLightSidePlayer ? row.reversed : row - 1, col: col);
  }
}
