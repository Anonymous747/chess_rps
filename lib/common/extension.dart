import 'package:chess_rps/domain/model/cell.dart';
import 'package:chess_rps/domain/model/position.dart';

extension HashDecoderExtension on String {
  Position toPosition() {
    final cords = split(separatedSign);
    final row = int.parse(cords[0]);
    final col = int.parse(cords[1]);

    return Position(row: row, col: col);
  }
}
