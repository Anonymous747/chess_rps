// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'game_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$GameState {
  Board get board => throw _privateConstructorUsedError;
  Side get currentOrder => throw _privateConstructorUsedError;
  String? get selectedFigure => throw _privateConstructorUsedError;
  Side get playerSide => throw _privateConstructorUsedError;
  bool get showRpsOverlay => throw _privateConstructorUsedError;
  RpsChoice? get playerRpsChoice => throw _privateConstructorUsedError;
  RpsChoice? get opponentRpsChoice => throw _privateConstructorUsedError;
  bool get waitingForRpsResult => throw _privateConstructorUsedError;
  bool? get playerWonRps => throw _privateConstructorUsedError;
  int get lightPlayerTimeSeconds => throw _privateConstructorUsedError;
  int get darkPlayerTimeSeconds => throw _privateConstructorUsedError;
  DateTime? get currentTurnStartedAt => throw _privateConstructorUsedError;
  Side? get kingInCheck => throw _privateConstructorUsedError;
  List<String> get moveHistory => throw _privateConstructorUsedError;
  bool get gameOver => throw _privateConstructorUsedError;
  Side? get winner => throw _privateConstructorUsedError;
  bool get isCheckmate => throw _privateConstructorUsedError;
  bool get isStalemate => throw _privateConstructorUsedError;

  /// Create a copy of GameState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $GameStateCopyWith<GameState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GameStateCopyWith<$Res> {
  factory $GameStateCopyWith(GameState value, $Res Function(GameState) then) =
      _$GameStateCopyWithImpl<$Res, GameState>;
  @useResult
  $Res call(
      {Board board,
      Side currentOrder,
      String? selectedFigure,
      Side playerSide,
      bool showRpsOverlay,
      RpsChoice? playerRpsChoice,
      RpsChoice? opponentRpsChoice,
      bool waitingForRpsResult,
      bool? playerWonRps,
      int lightPlayerTimeSeconds,
      int darkPlayerTimeSeconds,
      DateTime? currentTurnStartedAt,
      Side? kingInCheck,
      List<String> moveHistory,
      bool gameOver,
      Side? winner,
      bool isCheckmate,
      bool isStalemate});
}

/// @nodoc
class _$GameStateCopyWithImpl<$Res, $Val extends GameState>
    implements $GameStateCopyWith<$Res> {
  _$GameStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of GameState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? board = null,
    Object? currentOrder = null,
    Object? selectedFigure = freezed,
    Object? playerSide = null,
    Object? showRpsOverlay = null,
    Object? playerRpsChoice = freezed,
    Object? opponentRpsChoice = freezed,
    Object? waitingForRpsResult = null,
    Object? playerWonRps = freezed,
    Object? lightPlayerTimeSeconds = null,
    Object? darkPlayerTimeSeconds = null,
    Object? currentTurnStartedAt = freezed,
    Object? kingInCheck = freezed,
    Object? moveHistory = null,
    Object? gameOver = null,
    Object? winner = freezed,
    Object? isCheckmate = null,
    Object? isStalemate = null,
  }) {
    return _then(_value.copyWith(
      board: null == board
          ? _value.board
          : board // ignore: cast_nullable_to_non_nullable
              as Board,
      currentOrder: null == currentOrder
          ? _value.currentOrder
          : currentOrder // ignore: cast_nullable_to_non_nullable
              as Side,
      selectedFigure: freezed == selectedFigure
          ? _value.selectedFigure
          : selectedFigure // ignore: cast_nullable_to_non_nullable
              as String?,
      playerSide: null == playerSide
          ? _value.playerSide
          : playerSide // ignore: cast_nullable_to_non_nullable
              as Side,
      showRpsOverlay: null == showRpsOverlay
          ? _value.showRpsOverlay
          : showRpsOverlay // ignore: cast_nullable_to_non_nullable
              as bool,
      playerRpsChoice: freezed == playerRpsChoice
          ? _value.playerRpsChoice
          : playerRpsChoice // ignore: cast_nullable_to_non_nullable
              as RpsChoice?,
      opponentRpsChoice: freezed == opponentRpsChoice
          ? _value.opponentRpsChoice
          : opponentRpsChoice // ignore: cast_nullable_to_non_nullable
              as RpsChoice?,
      waitingForRpsResult: null == waitingForRpsResult
          ? _value.waitingForRpsResult
          : waitingForRpsResult // ignore: cast_nullable_to_non_nullable
              as bool,
      playerWonRps: freezed == playerWonRps
          ? _value.playerWonRps
          : playerWonRps // ignore: cast_nullable_to_non_nullable
              as bool?,
      lightPlayerTimeSeconds: null == lightPlayerTimeSeconds
          ? _value.lightPlayerTimeSeconds
          : lightPlayerTimeSeconds // ignore: cast_nullable_to_non_nullable
              as int,
      darkPlayerTimeSeconds: null == darkPlayerTimeSeconds
          ? _value.darkPlayerTimeSeconds
          : darkPlayerTimeSeconds // ignore: cast_nullable_to_non_nullable
              as int,
      currentTurnStartedAt: freezed == currentTurnStartedAt
          ? _value.currentTurnStartedAt
          : currentTurnStartedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      kingInCheck: freezed == kingInCheck
          ? _value.kingInCheck
          : kingInCheck // ignore: cast_nullable_to_non_nullable
              as Side?,
      moveHistory: null == moveHistory
          ? _value.moveHistory
          : moveHistory // ignore: cast_nullable_to_non_nullable
              as List<String>,
      gameOver: null == gameOver
          ? _value.gameOver
          : gameOver // ignore: cast_nullable_to_non_nullable
              as bool,
      winner: freezed == winner
          ? _value.winner
          : winner // ignore: cast_nullable_to_non_nullable
              as Side?,
      isCheckmate: null == isCheckmate
          ? _value.isCheckmate
          : isCheckmate // ignore: cast_nullable_to_non_nullable
              as bool,
      isStalemate: null == isStalemate
          ? _value.isStalemate
          : isStalemate // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$GameStateImplCopyWith<$Res>
    implements $GameStateCopyWith<$Res> {
  factory _$$GameStateImplCopyWith(
          _$GameStateImpl value, $Res Function(_$GameStateImpl) then) =
      __$$GameStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {Board board,
      Side currentOrder,
      String? selectedFigure,
      Side playerSide,
      bool showRpsOverlay,
      RpsChoice? playerRpsChoice,
      RpsChoice? opponentRpsChoice,
      bool waitingForRpsResult,
      bool? playerWonRps,
      int lightPlayerTimeSeconds,
      int darkPlayerTimeSeconds,
      DateTime? currentTurnStartedAt,
      Side? kingInCheck,
      List<String> moveHistory,
      bool gameOver,
      Side? winner,
      bool isCheckmate,
      bool isStalemate});
}

/// @nodoc
class __$$GameStateImplCopyWithImpl<$Res>
    extends _$GameStateCopyWithImpl<$Res, _$GameStateImpl>
    implements _$$GameStateImplCopyWith<$Res> {
  __$$GameStateImplCopyWithImpl(
      _$GameStateImpl _value, $Res Function(_$GameStateImpl) _then)
      : super(_value, _then);

  /// Create a copy of GameState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? board = null,
    Object? currentOrder = null,
    Object? selectedFigure = freezed,
    Object? playerSide = null,
    Object? showRpsOverlay = null,
    Object? playerRpsChoice = freezed,
    Object? opponentRpsChoice = freezed,
    Object? waitingForRpsResult = null,
    Object? playerWonRps = freezed,
    Object? lightPlayerTimeSeconds = null,
    Object? darkPlayerTimeSeconds = null,
    Object? currentTurnStartedAt = freezed,
    Object? kingInCheck = freezed,
    Object? moveHistory = null,
    Object? gameOver = null,
    Object? winner = freezed,
    Object? isCheckmate = null,
    Object? isStalemate = null,
  }) {
    return _then(_$GameStateImpl(
      board: null == board
          ? _value.board
          : board // ignore: cast_nullable_to_non_nullable
              as Board,
      currentOrder: null == currentOrder
          ? _value.currentOrder
          : currentOrder // ignore: cast_nullable_to_non_nullable
              as Side,
      selectedFigure: freezed == selectedFigure
          ? _value.selectedFigure
          : selectedFigure // ignore: cast_nullable_to_non_nullable
              as String?,
      playerSide: null == playerSide
          ? _value.playerSide
          : playerSide // ignore: cast_nullable_to_non_nullable
              as Side,
      showRpsOverlay: null == showRpsOverlay
          ? _value.showRpsOverlay
          : showRpsOverlay // ignore: cast_nullable_to_non_nullable
              as bool,
      playerRpsChoice: freezed == playerRpsChoice
          ? _value.playerRpsChoice
          : playerRpsChoice // ignore: cast_nullable_to_non_nullable
              as RpsChoice?,
      opponentRpsChoice: freezed == opponentRpsChoice
          ? _value.opponentRpsChoice
          : opponentRpsChoice // ignore: cast_nullable_to_non_nullable
              as RpsChoice?,
      waitingForRpsResult: null == waitingForRpsResult
          ? _value.waitingForRpsResult
          : waitingForRpsResult // ignore: cast_nullable_to_non_nullable
              as bool,
      playerWonRps: freezed == playerWonRps
          ? _value.playerWonRps
          : playerWonRps // ignore: cast_nullable_to_non_nullable
              as bool?,
      lightPlayerTimeSeconds: null == lightPlayerTimeSeconds
          ? _value.lightPlayerTimeSeconds
          : lightPlayerTimeSeconds // ignore: cast_nullable_to_non_nullable
              as int,
      darkPlayerTimeSeconds: null == darkPlayerTimeSeconds
          ? _value.darkPlayerTimeSeconds
          : darkPlayerTimeSeconds // ignore: cast_nullable_to_non_nullable
              as int,
      currentTurnStartedAt: freezed == currentTurnStartedAt
          ? _value.currentTurnStartedAt
          : currentTurnStartedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      kingInCheck: freezed == kingInCheck
          ? _value.kingInCheck
          : kingInCheck // ignore: cast_nullable_to_non_nullable
              as Side?,
      moveHistory: null == moveHistory
          ? _value.moveHistory
          : moveHistory // ignore: cast_nullable_to_non_nullable
              as List<String>,
      gameOver: null == gameOver
          ? _value.gameOver
          : gameOver // ignore: cast_nullable_to_non_nullable
              as bool,
      winner: freezed == winner
          ? _value.winner
          : winner // ignore: cast_nullable_to_non_nullable
              as Side?,
      isCheckmate: null == isCheckmate
          ? _value.isCheckmate
          : isCheckmate // ignore: cast_nullable_to_non_nullable
              as bool,
      isStalemate: null == isStalemate
          ? _value.isStalemate
          : isStalemate // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc

class _$GameStateImpl implements _GameState {
  const _$GameStateImpl(
      {required this.board,
      this.currentOrder = Side.light,
      this.selectedFigure = null,
      this.playerSide = Side.light,
      this.showRpsOverlay = false,
      this.playerRpsChoice = null,
      this.opponentRpsChoice = null,
      this.waitingForRpsResult = false,
      this.playerWonRps = null,
      this.lightPlayerTimeSeconds = 600,
      this.darkPlayerTimeSeconds = 600,
      this.currentTurnStartedAt = null,
      this.kingInCheck = null,
      this.moveHistory = const [],
      this.gameOver = false,
      this.winner = null,
      this.isCheckmate = false,
      this.isStalemate = false});

  @override
  final Board board;
  @override
  @JsonKey()
  final Side currentOrder;
  @override
  @JsonKey()
  final String? selectedFigure;
  @override
  @JsonKey()
  final Side playerSide;
  @override
  @JsonKey()
  final bool showRpsOverlay;
  @override
  @JsonKey()
  final RpsChoice? playerRpsChoice;
  @override
  @JsonKey()
  final RpsChoice? opponentRpsChoice;
  @override
  @JsonKey()
  final bool waitingForRpsResult;
  @override
  @JsonKey()
  final bool? playerWonRps;
  @override
  @JsonKey()
  final int lightPlayerTimeSeconds;
  @override
  @JsonKey()
  final int darkPlayerTimeSeconds;
  @override
  @JsonKey()
  final DateTime? currentTurnStartedAt;
  @override
  @JsonKey()
  final Side? kingInCheck;
  @override
  @JsonKey()
  final List<String> moveHistory;
  @override
  @JsonKey()
  final bool gameOver;
  @override
  @JsonKey()
  final Side? winner;
  @override
  @JsonKey()
  final bool isCheckmate;
  @override
  @JsonKey()
  final bool isStalemate;

  @override
  String toString() {
    return 'GameState(board: $board, currentOrder: $currentOrder, selectedFigure: $selectedFigure, playerSide: $playerSide, showRpsOverlay: $showRpsOverlay, playerRpsChoice: $playerRpsChoice, opponentRpsChoice: $opponentRpsChoice, waitingForRpsResult: $waitingForRpsResult, playerWonRps: $playerWonRps, lightPlayerTimeSeconds: $lightPlayerTimeSeconds, darkPlayerTimeSeconds: $darkPlayerTimeSeconds, currentTurnStartedAt: $currentTurnStartedAt, kingInCheck: $kingInCheck, moveHistory: $moveHistory, gameOver: $gameOver, winner: $winner, isCheckmate: $isCheckmate, isStalemate: $isStalemate)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GameStateImpl &&
            (identical(other.board, board) || other.board == board) &&
            (identical(other.currentOrder, currentOrder) ||
                other.currentOrder == currentOrder) &&
            (identical(other.selectedFigure, selectedFigure) ||
                other.selectedFigure == selectedFigure) &&
            (identical(other.playerSide, playerSide) ||
                other.playerSide == playerSide) &&
            (identical(other.showRpsOverlay, showRpsOverlay) ||
                other.showRpsOverlay == showRpsOverlay) &&
            (identical(other.playerRpsChoice, playerRpsChoice) ||
                other.playerRpsChoice == playerRpsChoice) &&
            (identical(other.opponentRpsChoice, opponentRpsChoice) ||
                other.opponentRpsChoice == opponentRpsChoice) &&
            (identical(other.waitingForRpsResult, waitingForRpsResult) ||
                other.waitingForRpsResult == waitingForRpsResult) &&
            (identical(other.playerWonRps, playerWonRps) ||
                other.playerWonRps == playerWonRps) &&
            (identical(other.lightPlayerTimeSeconds, lightPlayerTimeSeconds) ||
                other.lightPlayerTimeSeconds == lightPlayerTimeSeconds) &&
            (identical(other.darkPlayerTimeSeconds, darkPlayerTimeSeconds) ||
                other.darkPlayerTimeSeconds == darkPlayerTimeSeconds) &&
            (identical(other.currentTurnStartedAt, currentTurnStartedAt) ||
                other.currentTurnStartedAt == currentTurnStartedAt) &&
            (identical(other.kingInCheck, kingInCheck) ||
                other.kingInCheck == kingInCheck) &&
            (identical(other.moveHistory, moveHistory) ||
                const DeepCollectionEquality().equals(other.moveHistory, moveHistory)) &&
            (identical(other.gameOver, gameOver) ||
                other.gameOver == gameOver) &&
            (identical(other.winner, winner) ||
                other.winner == winner) &&
            (identical(other.isCheckmate, isCheckmate) ||
                other.isCheckmate == isCheckmate) &&
            (identical(other.isStalemate, isStalemate) ||
                other.isStalemate == isStalemate));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      board,
      currentOrder,
      selectedFigure,
      playerSide,
      showRpsOverlay,
      playerRpsChoice,
      opponentRpsChoice,
      waitingForRpsResult,
      playerWonRps,
      lightPlayerTimeSeconds,
      darkPlayerTimeSeconds,
      currentTurnStartedAt,
      kingInCheck,
      moveHistory,
      gameOver,
      winner,
      isCheckmate,
      isStalemate);

  /// Create a copy of GameState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$GameStateImplCopyWith<_$GameStateImpl> get copyWith =>
      __$$GameStateImplCopyWithImpl<_$GameStateImpl>(this, _$identity);
}

abstract class _GameState implements GameState {
  const factory _GameState(
      {required final Board board,
      final Side currentOrder,
      final String? selectedFigure,
      final Side playerSide,
      final bool showRpsOverlay,
      final RpsChoice? playerRpsChoice,
      final RpsChoice? opponentRpsChoice,
      final bool waitingForRpsResult,
      final bool? playerWonRps,
      final int lightPlayerTimeSeconds,
      final int darkPlayerTimeSeconds,
      final DateTime? currentTurnStartedAt,
      final Side? kingInCheck,
      final List<String> moveHistory,
      final bool gameOver,
      final Side? winner,
      final bool isCheckmate,
      final bool isStalemate}) = _$GameStateImpl;

  @override
  Board get board;
  @override
  Side get currentOrder;
  @override
  String? get selectedFigure;
  @override
  Side get playerSide;
  @override
  bool get showRpsOverlay;
  @override
  RpsChoice? get playerRpsChoice;
  @override
  RpsChoice? get opponentRpsChoice;
  @override
  bool get waitingForRpsResult;
  @override
  bool? get playerWonRps;
  @override
  int get lightPlayerTimeSeconds;
  @override
  int get darkPlayerTimeSeconds;
  @override
  DateTime? get currentTurnStartedAt;
  @override
  Side? get kingInCheck;
  @override
  List<String> get moveHistory;
  @override
  bool get gameOver;
  @override
  Side? get winner;
  @override
  bool get isCheckmate;
  @override
  bool get isStalemate;

  /// Create a copy of GameState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$GameStateImplCopyWith<_$GameStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
