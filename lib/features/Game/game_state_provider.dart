import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:loup_garou/features/Game/models/win_condition.dart';
import 'package:loup_garou/features/Game/game_actions.dart';
import 'package:loup_garou/models/game_characters.dart';
import 'package:loup_garou/features/Game/models/game_state.dart';
import 'package:loup_garou/models/night_action_result.dart';
import 'package:loup_garou/providers/names_provider.dart';
import 'package:loup_garou/providers/roles_provider.dart';
import 'package:loup_garou/models/game_character.dart';

class GameStateNotifier extends Notifier<GameState> {
  @override
  GameState build() {
    final names = ref.read(namesProvider);
    final roles = ref.read(rolesProvider);
    final total = (names.length < roles.length) ? names.length : roles.length;
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
    ref.invalidate(nightContextProvider);
  }

  void _clearEffects() {
    state = state.copyWith(
      players: state.players.map((p) {
        if (p.isSilenced) {
          return p.copyWith(isSilenced: false);
        }
        return p;
      }).toList(),
    );
  }

  void setSilenced(GamePlayer player) {
    state = state.copyWith(
      players: state.players.map((p) {
        if (p.name == player.name) {
          return p.copyWith(isSilenced: true);
        }
        return p;
      }).toList(),
    );
  }

  /// Kill a player and handle their onKilled ability
  Future<void> votePlayer(GamePlayer player) async {
    // Update player's lives
    state = state.copyWith(
      players: _sortPlayers(
        state.players.map((p) {
          if (p.name == player.name) {
            return p.copyWith(lives: 0);
          }
          return p;
        }).toList(),
      ),
    );
    await player.gameCharacter.onVotedOut(
      actions: GameActions.fromNotifier(ref, this, state),
      self: player,
    );
  }

  /// Kill a player and handle their onKilled ability
  Future<void> killPlayer(GamePlayer player, GamePlayer killer) async {
    // Check if player will actually die (check current lives)
    final currentPlayer = state.players.firstWhere(
      (p) => p.name == player.name,
    );
    final willDie = currentPlayer.lives - 1 <= 0;

    // Update player's lives
    state = state.copyWith(
      players: _sortPlayers(
        state.players.map((p) {
          if (p.name == player.name) {
            return p.copyWith(lives: p.lives - 1);
          }
          return p;
        }).toList(),
      ),
    );

    // If player died, trigger their onKilled ability
    if (willDie) {
      ref
          .read(nightContextProvider.notifier)
          .addNightResult(player, Result.dead);
      await player.gameCharacter.onKilled(
        actions: GameActions.fromNotifier(ref, this, state),
        self: player,
        killer: killer,
      );
    }
  }

  void cursedChildKilled(GamePlayer player) {
    ref
        .read(nightContextProvider.notifier)
        .addNightResult(player, Result.transformed);

    state = state.copyWith(
      players: _sortPlayers(
        state.players.map((p) {
          if (p.name == player.name) {
            return p.copyWith(
              lives: SimpleWolf().lives,
              gameCharacter: SimpleWolf(),
            );
          }
          return p;
        }).toList(),
      ),
    );
  }

  void _setTalkingOrder(String? startName, String? direction) {
    final alive = getAlivePlayers();
    if (alive.isEmpty) {
      state = state.copyWith(talkingOrder: []);
      return;
    }
    List<GamePlayer>? talkingOrder;

    if (startName != null) {
      final startIdx = alive.indexWhere((p) => p.name == startName);
      if (startIdx == -1) {
        // Player not found, use default order
        talkingOrder = alive;
      } else if (direction == 'clockwise') {
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

  void nextDay() {
    _clearEffects();
    state = state.copyWith(isNight: !state.isNight);
  }

  void nextNight() {
    state = state.copyWith(
      isNight: !state.isNight,
      nightCount: state.nightCount + 1,
    );
  }

  /// Run the night phase with all character abilities
  Future<void> runNight() async {
    bool wolvesActed = false;

    final alivePlayers = state.players.where((p) => p.isAlive).toList();

    // Get unique roles and sort by priority
    final rolesInOrder =
        alivePlayers.map((p) => p.gameCharacter).toSet().toList()
          ..sort((a, b) => b.priority.compareTo(a.priority));

    // Execute each role's night action in priority order
    for (final role in rolesInOrder) {
      final playersWithRole = alivePlayers.where(
        (p) => p.gameCharacter == role,
      );

      for (final player in playersWithRole) {
        // Show wake phase dialog
        if (role.team == Team.wolves && !wolvesActed) {
          await (role as SimpleWolf).wolfsActions(
            actions: GameActions.fromNotifier(ref, this, state),
            self: player,
          );
          wolvesActed = true;
        }
        await role.nightAction(
          actions: GameActions.fromNotifier(ref, this, state),
          self: player,
        );
      }
    }

    // Finalize the night (kill players, etc.)
    await _finalizeNight();
  }

  void updateCharacterState(GamePlayer player, Map<String, dynamic> updates) {
    state = state.copyWith(
      players: state.players.map((p) {
        if (p.name == player.name) {
          final newState = Map<String, dynamic>.from(p.characterState);
          newState.addAll(updates);
          return p.copyWith(characterState: newState);
        }
        return p;
      }).toList(),
    );
  }

  /// Finalize the night by killing players
  Future<void> _finalizeNight() async {
    // Filter out protected players (they survive)
    final night = ref.read(nightContextProvider);

    final actuallyDying = night.toDie.entries
        .where(
          (entry) =>
              !(night.protected.contains(entry.key) &&
                  entry.value.gameCharacter.team == Team.wolves),
        )
        .toList();

    // Kill each player (this may trigger additional deaths like Hunter's revenge)
    for (final player in actuallyDying) {
      await killPlayer(player.key, player.value);
    }
    final startName = night.startName;
    final direction = night.direction;

    _setTalkingOrder(startName, direction);
  }

  // Add this method to set special wins (e.g., from character abilities)
  void setWinCondition(WinCondition condition) {
    state = state.copyWith(winCondition: condition);
  }

  /// Check if either team has won or if special win conditions are met
  bool checkWinCondition() {
    // First check if someone already won (e.g., Jester voted out)
    if (state.winCondition != null) {
      return true;
    }

    // Get all wolves and alive counts
    final wolves = state.players
        .where((p) => p.gameCharacter.team == Team.wolves)
        .toList();

    if (wolves.isEmpty) {
      // No wolves in game - this shouldn't happen in normal gameplay
      return false;
    }

    final deadWolves = wolves.where((p) => p.isDead).length;
    final totalWolves = wolves.length;

    // Village wins if all wolves are dead
    if (deadWolves == totalWolves) {
      state = state.copyWith(
        winCondition: WinCondition(
          message: 'Village wins! All wolves are dead.',
          winningTeam: Team.village,
        ),
      );
      return true;
    }

    final aliveWolves = wolves.where((p) => p.isAlive).length;
    final aliveVillagers = state.players
        .where((p) => p.isAlive && p.gameCharacter.team != Team.wolves)
        .length;

    // Wolves win if they kill all villagers
    if (aliveVillagers == 0 && aliveWolves > 0) {
      state = state.copyWith(
        winCondition: WinCondition(
          message: 'Wolves win! They killed all the villagers.',
          winningTeam: Team.wolves,
        ),
      );
      return true;
    }

    // Check for Serial Killer win
    final alivePlayers = getAlivePlayers();
    if (alivePlayers.length == 1 &&
        alivePlayers.first.gameCharacter is SerialKiller) {
      state = state.copyWith(
        winCondition: WinCondition(
          message:
              '${alivePlayers.first.name} (Serial Killer) wins! They are the last player alive.',
          winningTeam: Team.solo,
          winners: [alivePlayers.first],
        ),
      );
      return true;
    }

    return false;
  }

  List<GamePlayer> getAlivePlayers() {
    return state.players.where((p) => p.isAlive).toList();
  }
}

final gameStateProvider = NotifierProvider<GameStateNotifier, GameState>(() {
  return GameStateNotifier();
});
