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
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

/// @nodoc
mixin _$Cell {
  Side get side => throw _privateConstructorUsedError;
  Position get position => throw _privateConstructorUsedError;
  bool get isSelected => throw _privateConstructorUsedError;
  bool get isAvailable => throw _privateConstructorUsedError;
  Figure? get figure => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
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

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? side = null,
    Object? position = null,
    Object? isSelected = null,
    Object? isAvailable = null,
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
      figure: freezed == figure
          ? _value.figure
          : figure // ignore: cast_nullable_to_non_nullable
              as Figure?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$_CellCopyWith<$Res> implements $CellCopyWith<$Res> {
  factory _$$_CellCopyWith(_$_Cell value, $Res Function(_$_Cell) then) =
      __$$_CellCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {Side side,
      Position position,
      bool isSelected,
      bool isAvailable,
      Figure? figure});
}

/// @nodoc
class __$$_CellCopyWithImpl<$Res> extends _$CellCopyWithImpl<$Res, _$_Cell>
    implements _$$_CellCopyWith<$Res> {
  __$$_CellCopyWithImpl(_$_Cell _value, $Res Function(_$_Cell) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? side = null,
    Object? position = null,
    Object? isSelected = null,
    Object? isAvailable = null,
    Object? figure = freezed,
  }) {
    return _then(_$_Cell(
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
      figure: freezed == figure
          ? _value.figure
          : figure // ignore: cast_nullable_to_non_nullable
              as Figure?,
    ));
  }
}

/// @nodoc

class _$_Cell implements _Cell {
  _$_Cell(
      {required this.side,
      required this.position,
      this.isSelected = false,
      this.isAvailable = false,
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
  final Figure? figure;

  @override
  String toString() {
    return 'Cell(side: $side, position: $position, isSelected: $isSelected, isAvailable: $isAvailable, figure: $figure)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_Cell &&
            (identical(other.side, side) || other.side == side) &&
            (identical(other.position, position) ||
                other.position == position) &&
            (identical(other.isSelected, isSelected) ||
                other.isSelected == isSelected) &&
            (identical(other.isAvailable, isAvailable) ||
                other.isAvailable == isAvailable) &&
            (identical(other.figure, figure) || other.figure == figure));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, side, position, isSelected, isAvailable, figure);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_CellCopyWith<_$_Cell> get copyWith =>
      __$$_CellCopyWithImpl<_$_Cell>(this, _$identity);
}

abstract class _Cell implements Cell {
  factory _Cell(
      {required final Side side,
      required final Position position,
      final bool isSelected,
      final bool isAvailable,
      final Figure? figure}) = _$_Cell;

  @override
  Side get side;
  @override
  Position get position;
  @override
  bool get isSelected;
  @override
  bool get isAvailable;
  @override
  Figure? get figure;
  @override
  @JsonKey(ignore: true)
  _$$_CellCopyWith<_$_Cell> get copyWith => throw _privateConstructorUsedError;
}
