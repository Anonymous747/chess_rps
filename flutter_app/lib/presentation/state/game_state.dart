import 'package:chess_rps/common/enum.dart';
import 'package:chess_rps/common/rps_choice.dart';
import 'package:chess_rps/domain/model/board.dart';
import 'package:collection/collection.dart';
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
    @Default(null) Side? kingInCheck, // Which side's king is in check
    @Default([]) List<String> moveHistory, // History of all moves in algebraic notation
    @Default(false) bool gameOver, // Whether the game has ended
    @Default(null) Side? winner, // Which side won (null if draw/stalemate)
    @Default(false) bool isCheckmate, // Whether the game ended in checkmate
    @Default(false) bool isStalemate, // Whether the game ended in stalemate
  }) = _GameState;
}
