import 'package:chess_rps/common/enum.dart';
import 'package:chess_rps/model/figure.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'cell.freezed.dart';

const separatedSign = '-';

@freezed
class Cell with _$Cell {
  factory Cell({
    required Side side,
    required int row,
    required int column,
    @Default(null) Figure? figure,
    @Default(false) bool isSelected,
  }) = _Cell;
}

extension CellExtension on Cell {
  String get positionHash => '$row$separatedSign$column';
  bool get isOccupied => figure != null;
}
