import 'package:chess_rps/common/enum.dart';
import 'package:chess_rps/domain/model/board.dart';
import 'package:chess_rps/domain/model/figure.dart';
import 'package:chess_rps/domain/model/position.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'cell.freezed.dart';

const separatedSign = '-';

@freezed
class Cell with _$Cell {
  factory Cell({
    required Side side,
    required Position position,
    @Default(false) bool isSelected,
    @Default(false) bool isAvailable,
    @Default(false) bool canBeKnockedDown,
    @Default(null) Figure? figure,
  }) = _Cell;
}

extension CellExtension on Cell {
  String get positionHash => '${position.row}$separatedSign${position.col}';
  bool get isOccupied => figure != null;
  Side? get figureSide => figure?.side;

  bool calculateCanBeKnockedDown(Cell target) {
    return target.isOccupied &&
        figure != null &&
        target.figure != null &&
        figure?.side != target.figure?.side;
  }

  bool moveFigure(Board board, Cell to) {
    if (!isOccupied) return false;

    if (figure!.availableForMove(board, to)) {
      if (to.isOccupied) {
        assert(to.figure != null);

        board.pushKnockedFigure(to.figure!);
      }

      figure!.moveTo(to);

      return true;
    }

    return false;
  }
}
