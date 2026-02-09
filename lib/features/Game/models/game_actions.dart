import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:loup_garou/features/Game/providers/game_state_provider.dart';
import 'package:loup_garou/features/Game/models/game_state.dart';
import 'package:loup_garou/features/Game/models/win_condition.dart';
import 'package:loup_garou/features/Game/providers/night_action_result.dart';

class GameActions {
  final Ref ref;
  final GameStateNotifier? _stateNotifier;
  final GameState? _currentState; // Add this to hold state snapshot

  // Constructor for use from widgets/other providers
  GameActions(this.ref) : _stateNotifier = null, _currentState = null;

  // Constructor for use from within GameStateNotifier
  GameActions.fromNotifier(this.ref, this._stateNotifier, this._currentState);

  GameState get state {
    if (_currentState != null) {
      return _currentState; // Use the snapshot
    }
    return ref.read(gameStateProvider); // Read from provider when outside
  }

  NightContext get nightContext => ref.read(nightContextProvider);

  void addToDie(GamePlayer player, GamePlayer killer) {
    ref.read(nightContextProvider.notifier).addToDie(player, killer);
  }

  void removeFromDie(GamePlayer player) {
    ref.read(nightContextProvider.notifier).removeFromDie(player);
  }

  void addProtected(GamePlayer player) {
    ref.read(nightContextProvider.notifier).addProtected(player);
  }

  void updateCharacterState(GamePlayer player, Map<String, dynamic> updates) {
    if (_stateNotifier != null) {
      _stateNotifier.updateCharacterState(player, updates);
    } else {
      ref
          .read(gameStateProvider.notifier)
          .updateCharacterState(player, updates);
    }
  }

  Future<void> killPlayer(GamePlayer player, GamePlayer killer) async {
    if (_stateNotifier != null) {
      await _stateNotifier.killPlayer(player, killer);
    } else {
      await ref.read(gameStateProvider.notifier).killPlayer(player, killer);
    }
  }

  void setSilenced(GamePlayer player) {
    if (_stateNotifier != null) {
      _stateNotifier.setSilenced(player);
    } else {
      ref.read(gameStateProvider.notifier).setSilenced(player);
    }
  }

  void setStartNameAndDirection(String? name, String? direction) {
    ref
        .read(nightContextProvider.notifier)
        .setStartNameAndDirection(name, direction);
  }

  void cursedChildKilled(GamePlayer player) {
    if (_stateNotifier != null) {
      _stateNotifier.cursedChildKilled(player);
    } else {
      ref.read(gameStateProvider.notifier).cursedChildKilled(player);
    }
  }

  void littlePrinceOnVotedOut(GamePlayer player) {
    if (_stateNotifier != null) {
      _stateNotifier.littlePrinceOnVotedOut(player);
    } else {
      ref.read(gameStateProvider.notifier).littlePrinceOnVotedOut(player);
    }
  }

  void setWinCondition(WinCondition condition) {
    if (_stateNotifier != null) {
      _stateNotifier.setWinCondition(condition);
    } else {
      ref.read(gameStateProvider.notifier).setWinCondition(condition);
    }
  }
}
