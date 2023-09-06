import 'package:chess_rps/common/enum.dart';
import 'package:chess_rps/model/figure.dart';

class Cell {
  final Side side;
  final Figure? figure;

  bool get isOccupied => figure != null;

  const Cell({
    required this.side,
    this.figure,
  });
}
