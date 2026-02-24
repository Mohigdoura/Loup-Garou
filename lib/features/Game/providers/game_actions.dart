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

  // Instead of branching, unify access:
  GameStateNotifier get _notifier =>
      _stateNotifier ?? ref.read(gameStateProvider.notifier);
  GameState get state {
    if (_currentState != null) {
      return _currentState; // Use the snapshot
    }
    return ref.read(gameStateProvider); // Read from provider when outside
  }

  NightContext get nightContext => ref.read(nightContextProvider);

  void addKilledByWolves(GamePlayer player) {
    ref
        .read(nightContextProvider.notifier)
        .addNightEvent(player, Result.killedByWolves);
  }

  void addKilled(GamePlayer player) {
    ref
        .read(nightContextProvider.notifier)
        .addNightEvent(player, Result.killed);
  }

  void heal(GamePlayer player) {
    ref
        .read(nightContextProvider.notifier)
        .addNightEvent(player, Result.healed);
  }

  void addProtected(GamePlayer player) {
    ref
        .read(nightContextProvider.notifier)
        .addNightEvent(player, Result.protected);
  }

  void updateCharacterState(GamePlayer player, Map<String, dynamic> updates) {
    _notifier.updateCharacterState(player, updates);
  }

  Future<void> killPlayer(GamePlayer player) async {
    final nightEvent = NightEvent(player, Result.killed);
    await _notifier.killPlayer(nightEvent);
  }

  void setSilenced(GamePlayer player) {
    _notifier.setSilenced(player);
  }

  void setStartNameAndDirection(String? name, String? direction) {
    ref
        .read(nightContextProvider.notifier)
        .setStartNameAndDirection(name, direction);
  }

  void cursedChildKilled(GamePlayer player) {
    _notifier.cursedChildKilled(player);
  }

  void littlePrinceOnVotedOut(GamePlayer player) {
    _notifier.littlePrinceOnVotedOut(player);
  }

  void setWinCondition(WinCondition condition) {
    _notifier.setWinCondition(condition);
  }
}
