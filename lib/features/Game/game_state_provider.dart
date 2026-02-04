import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:loup_garou/models/game_state.dart';
import 'package:loup_garou/providers/names_provider.dart';
import 'package:loup_garou/providers/roles_provider.dart';
import 'package:loup_garou/models/game_character.dart';

class GameStateNotifier extends Notifier<GameState> {
  @override
  GameState build() {
    final names = ref.read(namesProvider);
    final roles = ref.read(rolesProvider);
    final total = (names.length < roles.length) ? names.length : roles.length;
    roles.shuffle();
    final players = List.generate(total, (i) {
      final role = roles[i];
      return GamePlayer(name: names[i], gameCharacter: role);
    });

    return GameState(players: _sortPlayers(players));
  }

  List<GamePlayer> _sortPlayers(List<GamePlayer> players) {
    final sortedPlayers = [...players];
    sortedPlayers.sort((a, b) {
      // Alive players first, dead players last
      if (a.isAlive && !b.isAlive) return -1;
      if (!a.isAlive && b.isAlive) return 1;
      return 0;
    });
    return sortedPlayers;
  }

  void resetGame() {
    ref.invalidateSelf();
  }

  void _clearSilenced() {
    state = state.copyWith(
      players: state.players.map((p) {
        if (p.isSilenced) {
          return p.copyWith(isSilenced: false); // ✅ Use copyWith
        }
        return p;
      }).toList(),
    );
  }

  void setSilenced(String name) {
    state = state.copyWith(
      players: state.players.map((p) {
        if (p.name == name) {
          return p.copyWith(isSilenced: true);
        }
        return p;
      }).toList(),
    );
  }

  void killPlayer(String name) {
    state = state.copyWith(
      players: _sortPlayers(
        state.players.map((p) {
          if (p.name == name) {
            p.killPlayer();
          }
          return p;
        }).toList(),
      ),
    );
  }

  void setLastProtectedPlayer(String name) {
    state = state = state.copyWith(
      players: state.players.map((p) {
        if (p.gameCharacter is Protector) {
          (p.gameCharacter as Protector).setlastProtectedPlayer(name);
        }
        return p;
      }).toList(),
    );
  }

  void _setTalkingOrder(String? startName, String? direction) {
    final alive = getAlivePlayers();
    List<GamePlayer>? talkingOrder;
    if (startName != null) {
      final startIdx = alive.indexWhere((p) => p.name == startName);
      if (direction == 'clockwise') {
        talkingOrder = [
          ...alive.sublist(startIdx),
          ...alive.sublist(0, startIdx),
        ];
      } else {
        final reversed = alive.reversed.toList();
        final revStartIdx = reversed.indexWhere((p) => p.name == startName);
        talkingOrder = [
          ...reversed.sublist(revStartIdx),
          ...reversed.sublist(0, revStartIdx),
        ];
      }
    } else {
      talkingOrder = alive;
    }
    state = state.copyWith(talkingOrder: talkingOrder);
  }

  void witchUseHealPotion() {
    state = state.copyWith(
      players: state.players.map((p) {
        if (p.gameCharacter is Witch) {
          (p.gameCharacter as Witch).useHealPotion();
        }
        return p;
      }).toList(),
    );
  }

  void witchUseKillPotion() {
    state = state.copyWith(
      players: state.players.map((p) {
        if (p.gameCharacter is Witch) {
          (p.gameCharacter as Witch).useKillPotion();
        }
        return p;
      }).toList(),
    );
  }

  void nextNight(String? startName, String? direction) {
    _setTalkingOrder(startName, direction);
    state = state.copyWith(
      nightCount: state.nightCount + 1,
      isNight: !state.isNight,
    );
  }

  void nextDay() {
    _clearSilenced();
    state = state.copyWith(isNight: !state.isNight);
  }

  bool checkWinCondition() {
    final deadWolves = state.players
        .where((p) => p.isDead && p.gameCharacter.team == Team.wolves)
        .length;
    final totalWolves = state.players
        .where((p) => p.gameCharacter.team == Team.wolves)
        .length;

    if (deadWolves == totalWolves && totalWolves > 0) {
      state = state.copyWith(
        gameOverMessage: 'Village wins! All wolves are dead.',
      );
      return true;
    }

    final aliveWolves = state.players
        .where((p) => p.isAlive && p.gameCharacter.team == Team.wolves)
        .length;
    final aliveVillagers = state.players
        .where((p) => p.isAlive && p.gameCharacter.team == Team.village)
        .length;

    if (aliveWolves > 0 && aliveWolves >= aliveVillagers) {
      state = state.copyWith(
        gameOverMessage: 'Wolves win! They outnumber villagers.',
      );
      return true;
    }

    return false;
  }

  List<GamePlayer> getAlivePlayers() {
    return state.players.where((p) => p.isAlive).toList();
  }

  List<GamePlayer> getActorsForNight() {
    final actors = state.players
        .where((p) => p.isAlive && p.gameCharacter.canActTonight())
        .toList();
    actors.sort(
      (a, b) => b.gameCharacter.priority.compareTo(a.gameCharacter.priority),
    );
    return actors;
  }
}

final gameStateProvider = NotifierProvider<GameStateNotifier, GameState>(() {
  return GameStateNotifier();
});
