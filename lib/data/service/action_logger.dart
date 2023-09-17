import 'package:chess_rps/domain/model/cell.dart';
import 'package:chess_rps/domain/service/logger.dart';

class ActionLogger implements Logger<Cell> {
  final List<Cell> _actions = [];

  @override
  void add(Cell note) => _actions.add(note);

  @override
  void clear() => _actions.clear();

  @override
  List<Cell> getAll() => _actions;

  @override
  bool remove(Cell note) => _actions.remove(note);
}
