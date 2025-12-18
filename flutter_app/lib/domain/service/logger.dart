import 'package:chess_rps/data/service/game/action_logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:riverpod/riverpod.dart';

part 'logger.g.dart';

@riverpod
Logger logger(Ref ref) {
  return ActionLogger();
}

abstract class Logger<T> {
  add(T note);
  remove(T note);
  clear();
  List<T> getAll();
}
