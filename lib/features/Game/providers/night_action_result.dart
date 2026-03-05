import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:loup_garou/features/Game/models/game_state.dart';

enum Result {
  Killed,
  Healed,
  HealedByWolves,
  Transformed,
  Seen,
  Protected,
  RoleStolen,
  Survived,
}

class NightEvent {
  final GamePlayer player;
  final Result result;

  NightEvent(this.player, this.result);
}

/// Context about the current night that characters can use
class NightContext {
  final List<NightEvent> nightEvents;
  final String? startName;
  final String? direction;

  NightContext({this.nightEvents = const [], this.startName, this.direction});

  NightContext copyWith({
    List<NightEvent>? nightEvents,
    String? startName,
    String? direction,
  }) {
    return NightContext(
      nightEvents: nightEvents ?? this.nightEvents,
      startName: startName ?? this.startName,
      direction: direction ?? this.direction,
    );
  }
}

class NightContextNotifier extends Notifier<NightContext> {
  @override
  NightContext build() {
    return NightContext();
  }

  void addNightEvent(GamePlayer player, Result result) {
    final event = NightEvent(player, result);
    log("new night event: ${event.result} for ${event.player.name}");
    state = state.copyWith(nightEvents: [...(state.nightEvents), event]);
  }

  void removeNightEvent(GamePlayer player, Result result) {
    state = state.copyWith(
      nightEvents: state.nightEvents
          .where((e) => !(e.player.name == player.name && e.result == result))
          .toList(),
    );
  }

  List<NightEvent> showNightResults() {
    final results = state.nightEvents
        .where(
          (event) =>
              event.result != Result.HealedByWolves &&
              event.result != Result.Killed &&
              event.result != Result.Healed &&
              event.result != Result.Protected,
        )
        .toList();
    results.addAll(actuallyDying());
    return results;
  }

  List<NightEvent> actuallyDying() {
    List<NightEvent> killedByWolvesPlayers = state.nightEvents
        .where((event) => event.result == Result.HealedByWolves)
        .toList();
    List<NightEvent> protectedPlayers = state.nightEvents
        .where((event) => event.result == Result.Protected)
        .toList();
    List<NightEvent> healedPlayers = state.nightEvents
        .where((event) => event.result == Result.Healed)
        .toList();

    for (var protectedPlayer in protectedPlayers) {
      killedByWolvesPlayers.removeWhere(
        (element) => element.player.name == protectedPlayer.player.name,
      );
    }

    List<NightEvent> killedPlayers = state.nightEvents
        .where((event) => event.result == Result.Killed)
        .toList();

    for (var healedPlayer in healedPlayers) {
      killedByWolvesPlayers.removeWhere(
        (element) => element.player.name == healedPlayer.player.name,
      );
      killedPlayers.removeWhere(
        (element) => element.player.name == healedPlayer.player.name,
      );
    }

    killedPlayers.addAll(killedByWolvesPlayers);

    // Deduplicate and unify under Result.dead
    return killedPlayers.fold<List<NightEvent>>([], (acc, e) {
      if (!acc.any((x) => x.player.name == e.player.name)) acc.add(e);
      return acc;
    });
  }

  void setStartNameAndDirection(String? startName, String? direction) {
    state = state.copyWith(startName: startName, direction: direction);
  }
}

final nightContextProvider =
    NotifierProvider<NightContextNotifier, NightContext>(() {
      return NightContextNotifier();
    });
