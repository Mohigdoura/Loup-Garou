import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:loup_garou/providers/shared_prefs_provider.dart';

class CoinsProvider extends Notifier<int> {
  @override
  int build() {
    final prefs = ref.read(sharedPrefsProvider);
    final coins = prefs.getInt('coins') ?? 0;
    return kDebugMode ? 100000 : coins;
  }

  Future<void> addCoins(int amount) async {
    final prefs = ref.read(sharedPrefsProvider);
    final newCoins = state + amount;
    await prefs.setInt('coins', newCoins);
    state = newCoins;
  }

  Future<void> decrementCoins(int amount) async {
    final prefs = ref.read(sharedPrefsProvider);
    final newCoins = state - amount;
    await prefs.setInt('coins', newCoins);
    state = newCoins;
  }
}

final coinsProvider = NotifierProvider<CoinsProvider, int>(
  () => CoinsProvider(),
);
