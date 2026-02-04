import 'package:loup_garou/models/game_state.dart';

class NightContext {
  final Set<GamePlayer> toDie;
  final Set<GamePlayer> protected;

  NightContext({
    Set<GamePlayer>? toDie,
    Set<GamePlayer>? protected,
    List<String>? logs,
  }) : toDie = toDie ?? {},
       protected = protected ?? {};
}

class NightActionResult {
  final ActionType type;
  final GamePlayer actor;
  final GamePlayer? target;

  const NightActionResult({
    required this.type,
    required this.actor,
    this.target,
  });
}

enum ActionType { kill, protect, heal }
