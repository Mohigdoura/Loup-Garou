import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:loup_garou/providers/shared_prefs_provider.dart';

class NamesNotifier extends Notifier<List<String>> {
  @override
  List<String> build() {
    final _prefs = ref.watch(sharedPrefsProvider);
    final savedNames = _prefs.getStringList('player_names');
    if (savedNames != null) return savedNames;
    return [];
  }

  Future<void> addName(String name) async {
    final _prefs = ref.watch(sharedPrefsProvider);

    final currentState = state;
    final newState = [...currentState, name];
    state = newState;
    await _prefs.setStringList('player_names', newState);
  }

  Future<void> removeAt(int index) async {
    final _prefs = ref.watch(sharedPrefsProvider);

    final currentState = state;
    final newState = [
      ...currentState.sublist(0, index),
      ...currentState.sublist(index + 1),
    ];
    state = newState;
    await _prefs.setStringList('player_names', newState);
  }

  Future<void> clear() async {
    final _prefs = ref.watch(sharedPrefsProvider);

    state = [];
    await _prefs.setStringList('player_names', []);
  }

  Future<void> updateName(int index, String newName) async {
    final _prefs = ref.watch(sharedPrefsProvider);

    final currentState = state;
    final newState = [
      ...currentState.sublist(0, index),
      newName,
      ...currentState.sublist(index + 1),
    ];
    state = newState;
    await _prefs.setStringList('player_names', newState);
  }

  Future<void> moveName(int from, int to) async {
    final _prefs = ref.watch(sharedPrefsProvider);

    final currentState = state;
    final newState = List<String>.from(currentState);
    final item = newState.removeAt(from);
    newState.insert(to, item);
    state = newState;
    await _prefs.setStringList('player_names', newState);
  }
}

final namesProvider = NotifierProvider<NamesNotifier, List<String>>(() {
  return NamesNotifier();
});
