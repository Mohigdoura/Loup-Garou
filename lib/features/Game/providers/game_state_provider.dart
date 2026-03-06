import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:loup_garou/features/Game/models/win_condition.dart';
import 'package:loup_garou/features/Game/providers/game_actions.dart';
import 'package:loup_garou/models/game_characters.dart';
import 'package:loup_garou/features/Game/models/game_state.dart';
import 'package:loup_garou/features/Game/providers/night_action_result.dart';
import 'package:loup_garou/features/setup/providers/names_provider.dart';
import 'package:loup_garou/features/setup/providers/roles_provider.dart';
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
  void votePlayer(GamePlayer player) {
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
    player.gameCharacter.onVotedOut(
      actions: GameActions.fromNotifier(ref, this, state),
      self: player,
    );
  }

  void littlePrinceOnVotedOut(GamePlayer player) {
    state = state.copyWith(
      players: _sortPlayers(
        state.players.map((p) {
          if (p.name == player.name) {
            return p.copyWith(lives: player.gameCharacter.lives);
          }
          return p;
        }).toList(),
      ),
    );
  }

  Future<void> dayAbility(GamePlayer player) async {
    await player.gameCharacter.dayAction(
      actions: GameActions.fromNotifier(ref, this, state),
      self: player,
    );
  }

  /// Kill a player and handle their onKilled ability
  void killPlayer(NightEvent event) {
    final player = event.player;
    final currentPlayer = state.players.firstWhere(
      (p) => p.name == player.name,
    );
    final willDie = currentPlayer.lives - 1 <= 0;

    state = state.copyWith(
      players: _sortPlayers(
        state.players.map((p) {
          if (p.name == player.name) return p.copyWith(lives: p.lives - 1);
          return p;
        }).toList(),
      ),
    );

    if (willDie) {
      player.gameCharacter.onKilled(
        actions: GameActions.fromNotifier(ref, this, state),
        nightEvent: event,
      );

      final playerAfterKill = state.players.firstWhere(
        (p) => p.name == player.name,
      );
      final actuallyDead = playerAfterKill.isDead;

      if (actuallyDead) {
        _graveRobberCheck(player);
      }
    } else {
      ref
          .read(nightContextProvider.notifier)
          .removeNightEvent(player, Result.Killed);
      ref
          .read(nightContextProvider.notifier)
          .removeNightEvent(player, Result.HealedByWolves);
    }
  }

  void princessKilled(GamePlayer player) {
    ref
        .read(nightContextProvider.notifier)
        .addNightEvent(player, Result.Survived);
    ref
        .read(nightContextProvider.notifier)
        .removeNightEvent(player, Result.HealedByWolves);

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

  void cursedChildKilled(GamePlayer player) {
    ref
        .read(nightContextProvider.notifier)
        .addNightEvent(player, Result.Transformed);
    ref
        .read(nightContextProvider.notifier)
        .removeNightEvent(player, Result.HealedByWolves);

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

  void _graveRobberCheck(GamePlayer deadPlayer) {
    // Find all alive GraveRobbers watching this exact player
    final watchers = state.players
        .where(
          (p) =>
              p.isAlive &&
              p.gameCharacter is GraveRobber &&
              p.characterState['watchingTarget'] == deadPlayer.name,
        )
        .toList();

    if (watchers.isEmpty) return;

    final stolenRole = deadPlayer.gameCharacter;
    ref
        .read(nightContextProvider.notifier)
        .addNightEvent(deadPlayer, Result.RoleStolen);

    // All watchers steal the role (handles multiple GraveRobbers)
    state = state.copyWith(
      players: state.players.map((p) {
        if (watchers.any((w) => w.name == p.name)) {
          return p.copyWith(
            gameCharacter: stolenRole,
            lives: stolenRole.lives,
            characterState: {},
          );
        }
        return p;
      }).toList(),
    );
  }

  void nextDay() {
    state = state.copyWith(isNight: !state.isNight);
  }

  void nextNight() {
    ref.invalidate(nightContextProvider);
    _clearEffects();
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
    final isAncientAlive = rolesInOrder
        .where((element) => element.name == 'Ancient')
        .isNotEmpty;
    log("rolesInOrder: $rolesInOrder");
    log("Anvient is alive: $isAncientAlive");
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
        if (role.team == Team.village && !isAncientAlive) continue;
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
    final nightNotifier = ref.read(nightContextProvider.notifier);

    final actuallyDying = nightNotifier.actuallyDying();

    // Kill each player (this may trigger additional deaths like Hunter's revenge)
    for (final player in actuallyDying) {
      killPlayer(player);
    }
    final startName = night.startName;
    final direction = night.direction;

    state = state.copyWith(startName: startName, direction: direction);
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
    final wolves = state.players
        .where((element) => element.gameCharacter.team == Team.wolves)
        .toList();
    final villagers = state.players
        .where((element) => element.gameCharacter.team == Team.village)
        .toList();
    final alivePlayers = state.alivePlayers;
    final aliveVillagers = state.aliveVillagers;
    final aliveWolves = state.aliveWolves;
    final aliveKillers = alivePlayers
        .where((element) => element.gameCharacter.name == 'Serial Killer')
        .toList();

    // Village wins if all wolves are dead
    if (aliveWolves.isEmpty &&
        aliveKillers.isEmpty &&
        aliveVillagers.isNotEmpty) {
      state = state.copyWith(
        winCondition: WinCondition(
          winningTeam: Team.village,
          winners: villagers,
        ),
      );
      return true;
    }

    // Wolves win if they kill all villagers
    if (aliveVillagers.isEmpty &&
        aliveWolves.isNotEmpty &&
        aliveKillers.isEmpty) {
      state = state.copyWith(
        winCondition: WinCondition(winningTeam: Team.wolves, winners: wolves),
      );
      return true;
    }

    // Check for Serial Killer win
    if (alivePlayers.length == 1) {
      state = state.copyWith(
        winCondition: WinCondition(
          winningTeam: alivePlayers.first.gameCharacter.team,
          winners: [alivePlayers.first],
        ),
      );
      return true;
    }

    return false;
  }
}

final gameStateProvider = NotifierProvider<GameStateNotifier, GameState>(() {
  return GameStateNotifier();
});
