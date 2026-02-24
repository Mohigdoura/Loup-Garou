// names_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:loup_garou/providers/shared_prefs_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _kAllPlayersKey = 'all_saved_players';
const _kLastPlayedKey = 'last_played';

class NamesNotifier extends Notifier<List<String>> {
  @override
  List<String> build() {
    // Start session with last played names (if any)
    return _prefs.getStringList(_kLastPlayedKey) ?? [];
  }

  SharedPreferences get _prefs => ref.read(sharedPrefsProvider);

  // All names ever used (the "saved list" for suggestions)
  List<String> get allSavedPlayers =>
      _prefs.getStringList(_kAllPlayersKey) ?? [];

  // Names not yet in current session (for the picker)
  List<String> get availableToAdd =>
      allSavedPlayers.where((n) => !state.contains(n)).toList();

  Future<void> addName(String name) async {
    if (state.contains(name)) return;
    state = [...state, name];

    // Persist to all-players list if new
    final all = allSavedPlayers;
    if (!all.contains(name)) {
      await _prefs.setStringList(_kAllPlayersKey, [...all, name]);
    }
  }

  Future<void> addNames(List<String> names) async {
    for (final name in names) {
      await addName(name);
    }
  }

  Future<void> removeAt(int index) async {
    final newState = List<String>.from(state)..removeAt(index);
    state = newState;
  }

  Future<void> updateName(int index, String newName) async {
    if (state.where((n) => n != state[index]).contains(newName)) return;
    final newState = List<String>.from(state)..[index] = newName;
    state = newState;

    // Update in all-players too
    final all = List<String>.from(allSavedPlayers);
    final allIndex = all.indexOf(state[index]);
    if (allIndex != -1) all[allIndex] = newName;
    if (!all.contains(newName)) all.add(newName);
    await _prefs.setStringList(_kAllPlayersKey, all);
  }

  Future<void> moveName(int from, int to) async {
    final newState = List<String>.from(state);
    final item = newState.removeAt(from);
    newState.insert(to, item);
    state = newState;
  }

  Future<void> removeFromSavedList(String name) async {
    final all = List<String>.from(allSavedPlayers)..remove(name);
    await _prefs.setStringList(_kAllPlayersKey, all);
    // Also remove from session if present
    if (state.contains(name)) {
      state = state.where((n) => n != name).toList();
    }
  }

  /// Call this when the game starts to persist the current session as last played
  Future<void> saveAsLastPlayed() async {
    await _prefs.setStringList(_kLastPlayedKey, state);
  }

  Future<void> clear() async {
    state = [];
  }
}

final namesProvider = NotifierProvider<NamesNotifier, List<String>>(
  NamesNotifier.new,
);
