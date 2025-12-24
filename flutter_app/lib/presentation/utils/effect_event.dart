import 'package:chess_rps/domain/model/position.dart';

/// Event representing a game effect that should be applied
class EffectEvent {
  final EffectEventType type;
  final String? effectName;
  final Position? fromPosition;
  final Position? toPosition;

  const EffectEvent({
    required this.type,
    this.effectName,
    this.fromPosition,
    this.toPosition,
  });
}

enum EffectEventType {
  move,
  capture,
}

