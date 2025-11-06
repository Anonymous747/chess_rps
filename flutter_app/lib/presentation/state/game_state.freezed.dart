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
  dynamic get playerSide => throw _privateConstructorUsedError;

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
      dynamic playerSide});
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
    Object? playerSide = freezed,
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
      playerSide: freezed == playerSide
          ? _value.playerSide
          : playerSide // ignore: cast_nullable_to_non_nullable
              as dynamic,
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
      dynamic playerSide});
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
    Object? playerSide = freezed,
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
      playerSide: freezed == playerSide ? _value.playerSide! : playerSide,
    ));
  }
}

/// @nodoc

class _$GameStateImpl implements _GameState {
  const _$GameStateImpl(
      {required this.board,
      this.currentOrder = Side.light,
      this.selectedFigure = null,
      this.playerSide = Side.light});

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
  final dynamic playerSide;

  @override
  String toString() {
    return 'GameState(board: $board, currentOrder: $currentOrder, selectedFigure: $selectedFigure, playerSide: $playerSide)';
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
            const DeepCollectionEquality()
                .equals(other.playerSide, playerSide));
  }

  @override
  int get hashCode => Object.hash(runtimeType, board, currentOrder,
      selectedFigure, const DeepCollectionEquality().hash(playerSide));

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
      final dynamic playerSide}) = _$GameStateImpl;

  @override
  Board get board;
  @override
  Side get currentOrder;
  @override
  String? get selectedFigure;
  @override
  dynamic get playerSide;

  /// Create a copy of GameState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$GameStateImplCopyWith<_$GameStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
