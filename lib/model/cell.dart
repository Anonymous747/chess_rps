import 'package:chess_rps/common/enum.dart';
import 'package:chess_rps/model/figure.dart';
import 'package:chess_rps/model/position.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'cell.freezed.dart';

const separatedSign = '-';

@freezed
class Cell with _$Cell {
  factory Cell({
    required Side side,
    required Position position,
    @Default(false) bool isSelected,
    @Default(null) Figure? figure,
  }) = _Cell;
}

extension CellExtension on Cell {
  String get positionHash => '${position.row}$separatedSign${position.col}';
  bool get isOccupied => figure != null;
}
