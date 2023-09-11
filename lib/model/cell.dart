import 'package:chess_rps/common/enum.dart';
import 'package:chess_rps/model/figure.dart';

class Cell {
  final Side side;
  final int row;
  final int column;
  final bool isSelected;

  Figure? figure;

  String get positionHash => '$row-$column';

  bool get isOccupied => figure != null;

  Cell({
    required this.side,
    required this.row,
    required this.column,
    this.isSelected = false,
    this.figure,
  });
}
