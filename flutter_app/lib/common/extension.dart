import 'package:chess_rps/domain/model/board.dart';
import 'package:chess_rps/domain/model/cell.dart';
import 'package:chess_rps/domain/model/position.dart';

extension HashDecoderExtension on String {
  /// Converts from hash notation to Position
  ///
  Position toPosition() {
    final cords = split(separatedSign);
    final row = int.parse(cords[0]);
    final col = int.parse(cords[1]);

    return Position(row: row, col: col);
  }
}

extension PositionExtension on int {
  /// Show which position is on the other side
  ///
  int get reversed {
    assert(0 <= this && this <= cellsRowCount);
    return cellsRowCount - this;
  }
}

extension NullableStringExtension on String? {
  bool get isNullOrEmpty => this == null || this!.isEmpty;
  bool get isNotNullOrEmpty => this != null && this!.isNotEmpty;
}
