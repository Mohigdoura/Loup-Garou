import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:loup_garou/providers/shared_prefs_provider.dart';

class CoinsProvider extends Notifier<int> {
  @override
  int build() {
    final prefs = ref.read(sharedPrefsProvider);
    final coins = prefs.getInt('coins') ?? 0;
    return coins;
  }

  void addCoins(int amount) {
    final prefs = ref.read(sharedPrefsProvider);
    final newCoins = state + amount;
    prefs.setInt('coins', newCoins);
    state = newCoins;
  }

  void decrementCoins(int amount) {
    final prefs = ref.read(sharedPrefsProvider);
    final newCoins = state - amount;
    prefs.setInt('coins', newCoins);
    state = newCoins;
  }
}

final coinsProvider = NotifierProvider<CoinsProvider, int>(
  () => CoinsProvider(),
);
