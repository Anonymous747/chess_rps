// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'cell.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$Cell {
  Side get side => throw _privateConstructorUsedError;
  Position get position => throw _privateConstructorUsedError;
  bool get isSelected => throw _privateConstructorUsedError;
  bool get isAvailable => throw _privateConstructorUsedError;
  bool get canBeKnockedDown => throw _privateConstructorUsedError;
  Figure? get figure => throw _privateConstructorUsedError;

  /// Create a copy of Cell
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CellCopyWith<Cell> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CellCopyWith<$Res> {
  factory $CellCopyWith(Cell value, $Res Function(Cell) then) =
      _$CellCopyWithImpl<$Res, Cell>;
  @useResult
  $Res call(
      {Side side,
      Position position,
      bool isSelected,
      bool isAvailable,
      bool canBeKnockedDown,
      Figure? figure});
}

/// @nodoc
class _$CellCopyWithImpl<$Res, $Val extends Cell>
    implements $CellCopyWith<$Res> {
  _$CellCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Cell
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? side = null,
    Object? position = null,
    Object? isSelected = null,
    Object? isAvailable = null,
    Object? canBeKnockedDown = null,
    Object? figure = freezed,
  }) {
    return _then(_value.copyWith(
      side: null == side
          ? _value.side
          : side // ignore: cast_nullable_to_non_nullable
              as Side,
      position: null == position
          ? _value.position
          : position // ignore: cast_nullable_to_non_nullable
              as Position,
      isSelected: null == isSelected
          ? _value.isSelected
          : isSelected // ignore: cast_nullable_to_non_nullable
              as bool,
      isAvailable: null == isAvailable
          ? _value.isAvailable
          : isAvailable // ignore: cast_nullable_to_non_nullable
              as bool,
      canBeKnockedDown: null == canBeKnockedDown
          ? _value.canBeKnockedDown
          : canBeKnockedDown // ignore: cast_nullable_to_non_nullable
              as bool,
      figure: freezed == figure
          ? _value.figure
          : figure // ignore: cast_nullable_to_non_nullable
              as Figure?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$CellImplCopyWith<$Res> implements $CellCopyWith<$Res> {
  factory _$$CellImplCopyWith(
          _$CellImpl value, $Res Function(_$CellImpl) then) =
      __$$CellImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {Side side,
      Position position,
      bool isSelected,
      bool isAvailable,
      bool canBeKnockedDown,
      Figure? figure});
}

/// @nodoc
class __$$CellImplCopyWithImpl<$Res>
    extends _$CellCopyWithImpl<$Res, _$CellImpl>
    implements _$$CellImplCopyWith<$Res> {
  __$$CellImplCopyWithImpl(_$CellImpl _value, $Res Function(_$CellImpl) _then)
      : super(_value, _then);

  /// Create a copy of Cell
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? side = null,
    Object? position = null,
    Object? isSelected = null,
    Object? isAvailable = null,
    Object? canBeKnockedDown = null,
    Object? figure = freezed,
  }) {
    return _then(_$CellImpl(
      side: null == side
          ? _value.side
          : side // ignore: cast_nullable_to_non_nullable
              as Side,
      position: null == position
          ? _value.position
          : position // ignore: cast_nullable_to_non_nullable
              as Position,
      isSelected: null == isSelected
          ? _value.isSelected
          : isSelected // ignore: cast_nullable_to_non_nullable
              as bool,
      isAvailable: null == isAvailable
          ? _value.isAvailable
          : isAvailable // ignore: cast_nullable_to_non_nullable
              as bool,
      canBeKnockedDown: null == canBeKnockedDown
          ? _value.canBeKnockedDown
          : canBeKnockedDown // ignore: cast_nullable_to_non_nullable
              as bool,
      figure: freezed == figure
          ? _value.figure
          : figure // ignore: cast_nullable_to_non_nullable
              as Figure?,
    ));
  }
}

/// @nodoc

class _$CellImpl implements _Cell {
  _$CellImpl(
      {required this.side,
      required this.position,
      this.isSelected = false,
      this.isAvailable = false,
      this.canBeKnockedDown = false,
      this.figure = null});

  @override
  final Side side;
  @override
  final Position position;
  @override
  @JsonKey()
  final bool isSelected;
  @override
  @JsonKey()
  final bool isAvailable;
  @override
  @JsonKey()
  final bool canBeKnockedDown;
  @override
  @JsonKey()
  final Figure? figure;

  @override
  String toString() {
    return 'Cell(side: $side, position: $position, isSelected: $isSelected, isAvailable: $isAvailable, canBeKnockedDown: $canBeKnockedDown, figure: $figure)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CellImpl &&
            (identical(other.side, side) || other.side == side) &&
            (identical(other.position, position) ||
                other.position == position) &&
            (identical(other.isSelected, isSelected) ||
                other.isSelected == isSelected) &&
            (identical(other.isAvailable, isAvailable) ||
                other.isAvailable == isAvailable) &&
            (identical(other.canBeKnockedDown, canBeKnockedDown) ||
                other.canBeKnockedDown == canBeKnockedDown) &&
            (identical(other.figure, figure) || other.figure == figure));
  }

  @override
  int get hashCode => Object.hash(runtimeType, side, position, isSelected,
      isAvailable, canBeKnockedDown, figure);

  /// Create a copy of Cell
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CellImplCopyWith<_$CellImpl> get copyWith =>
      __$$CellImplCopyWithImpl<_$CellImpl>(this, _$identity);
}

abstract class _Cell implements Cell {
  factory _Cell(
      {required final Side side,
      required final Position position,
      final bool isSelected,
      final bool isAvailable,
      final bool canBeKnockedDown,
      final Figure? figure}) = _$CellImpl;

  @override
  Side get side;
  @override
  Position get position;
  @override
  bool get isSelected;
  @override
  bool get isAvailable;
  @override
  bool get canBeKnockedDown;
  @override
  Figure? get figure;

  /// Create a copy of Cell
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CellImplCopyWith<_$CellImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
