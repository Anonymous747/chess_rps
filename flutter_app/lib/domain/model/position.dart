import 'dart:math';

class Position {
  final int row;
  final int col;

  const Position({required this.row, required this.col});

  int get magnitude => sqrt(col * col + row * row).toInt();
}
