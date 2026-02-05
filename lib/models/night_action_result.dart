import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:loup_garou/features/Game/models/game_state.dart';

enum Result { dead, transformed }

/// Context about the current night that characters can use
class NightContext {
  final Map<GamePlayer, GamePlayer> toDie;
  final List<GamePlayer> protected;
  final Map<GamePlayer, Result> nightResult;
  final String? startName;
  final String? direction;

  NightContext({
    Map<GamePlayer, GamePlayer>? toDie, // Make nullable
    List<GamePlayer>? protected, // Make nullable
    Map<GamePlayer, Result>? nightResult,
    this.startName,
    this.direction,
  }) : toDie =
           toDie ?? <GamePlayer, GamePlayer>{}, // Initialize with mutable list
       protected = protected ?? <GamePlayer>[],
       nightResult = nightResult ?? {};

  NightContext copyWith({
    Map<GamePlayer, GamePlayer>? toDie,
    List<GamePlayer>? protected,
    Map<GamePlayer, Result>? nightResult,
    String? startName,
    String? direction,
  }) {
    return NightContext(
      toDie:
          toDie ??
          Map<GamePlayer, GamePlayer>.from(this.toDie), // Copy the list
      protected: protected ?? List<GamePlayer>.from(this.protected),
      nightResult:
          nightResult ?? Map<GamePlayer, Result>.from(this.nightResult),
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

  void addToDie(GamePlayer player, GamePlayer killer) {
    if (!state.toDie.keys.contains(player)) {
      state = state.copyWith(toDie: {...state.toDie, player: killer});
    }
  }

  void addNightResult(GamePlayer player, Result result) {
    if (!state.nightResult.keys.contains(player)) {
      state = state.copyWith(
        nightResult: {...state.nightResult, player: result},
      );
    }
  }

  void removeFromDie(GamePlayer player) {
    state = state.copyWith(
      toDie: Map.fromEntries(
        state.toDie.entries.where((entry) => entry.key != player),
      ),
    );
  }

  void setStartNameAndDirection(String? startName, String? direction) {
    state = state.copyWith(startName: startName, direction: direction);
  }

  void addProtected(GamePlayer player) {
    if (!state.protected.contains(player)) {
      state = state.copyWith(protected: [...state.protected, player]);
    }
  }
}

final nightContextProvider =
    NotifierProvider<NightContextNotifier, NightContext>(() {
      return NightContextNotifier();
    });
