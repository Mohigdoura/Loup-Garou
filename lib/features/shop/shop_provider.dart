import 'dart:developer';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:loup_garou/features/shop/coins_provider.dart';
import 'package:loup_garou/providers/shared_prefs_provider.dart';

class ShopNotifier extends Notifier<Set<String>> {
  @override
  Set<String> build() {
    final prefs = ref.read(sharedPrefsProvider);
    final purchased = prefs.getStringList('purchased_roles') ?? [];
    return purchased.toSet();
  }

  /// Check if a role has been purchased
  bool isPurchased(String roleName) {
    return state.contains(roleName);
  }

  /// Check if a role can be purchased
  bool canPurchase(String roleName, int price, int currentCoins) {
    return !isPurchased(roleName) && currentCoins >= price;
  }

  /// Purchase a role and persist to storage
  Future<void> purchaseRole(String roleName, int price) async {
    if (state.contains(roleName)) {
      log("Role $roleName already purchased");
      return;
    }
    // Deduct coins
    await ref.read(coinsProvider.notifier).decrementCoins(price);

    final prefs = ref.read(sharedPrefsProvider);
    final newPurchased = {...state, roleName};

    // Save to persistent storage
    await prefs.setStringList('purchased_roles', newPurchased.toList());

    // Update state to notify listeners
    state = newPurchased;

    log("Purchased role: $roleName. Total: ${state.length}");
  }

  /// Clear all purchases (for testing/reset)
  Future<void> clearPurchases() async {
    final prefs = ref.read(sharedPrefsProvider);
    await prefs.remove('purchased_roles');
    state = {};
  }
}

final shopProvider = NotifierProvider<ShopNotifier, Set<String>>(() {
  return ShopNotifier();
});
