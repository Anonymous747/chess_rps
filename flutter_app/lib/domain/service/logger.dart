import 'package:chess_rps/data/service/game/action_logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'logger.g.dart';

@riverpod
Logger logger(LoggerRef ref) {
  return ActionLogger();
}

abstract class Logger<T> {
  add(T note);
  remove(T note);
  clear();
  List<T> getAll();
}
