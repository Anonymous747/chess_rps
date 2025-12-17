import 'package:chess_rps/common/enum.dart';
import 'package:chess_rps/common/rps_choice.dart';
import 'package:chess_rps/domain/model/board.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'game_state.freezed.dart';

@freezed
class GameState with _$GameState {
  const factory GameState({
    required Board board,
    @Default(Side.light) Side currentOrder,
    @Default(null) String? selectedFigure,
    @Default(Side.light) Side playerSide,
    @Default(false) bool showRpsOverlay,
    @Default(null) RpsChoice? playerRpsChoice,
    @Default(null) RpsChoice? opponentRpsChoice,
    @Default(false) bool waitingForRpsResult,
    @Default(null) bool? playerWonRps,
    @Default(600) int lightPlayerTimeSeconds, // 10 minutes
    @Default(600) int darkPlayerTimeSeconds, // 10 minutes
    @Default(null) DateTime? currentTurnStartedAt,
  }) = _GameState;
}
