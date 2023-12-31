import 'package:chess_rps/common/enum.dart';
import 'package:chess_rps/domain/model/board.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'game_state.freezed.dart';

@freezed
class GameState with _$GameState {
  const factory GameState({
    required Board board,
    @Default(Side.light) Side currentOrder,
    @Default(null) String? selectedFigure,
    @Default(Side.light) playerSide,
  }) = _GameState;
}
