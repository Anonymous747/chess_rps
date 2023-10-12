import 'package:chess_rps/domain/service/logger.dart';

class ActionLogger implements Logger<String> {
  final List<String> _actions = [];

  @override
  void add(String note) => _actions.add(note);

  @override
  void clear() => _actions.clear();

  @override
  List<String> getAll() => _actions;

  @override
  bool remove(String note) => _actions.remove(note);
}
