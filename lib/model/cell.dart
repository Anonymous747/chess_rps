import 'package:chess_rps/common/enum.dart';
import 'package:chess_rps/model/figure.dart';

class Cell {
  final Side side;
  Figure? figure;

  bool get isOccupied => figure != null;

  Cell({
    required this.side,
    this.figure,
  });
}
