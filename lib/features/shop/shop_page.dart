import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:loup_garou/features/shop/shop_provider.dart';
import 'package:loup_garou/models/game_character.dart';
import 'package:loup_garou/providers/ad_provider.dart';
import 'package:loup_garou/features/shop/coins_provider.dart';
import 'package:loup_garou/providers/roles_provider.dart';

class ShopPage extends ConsumerStatefulWidget {
  const ShopPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ShopPageState();
}

class _ShopPageState extends ConsumerState<ShopPage> {
  @override
  void initState() {
    super.initState();
    ref.read(adProvider.notifier).loadRewarded();
  }

  @override
  Widget build(BuildContext context) {
    // Watch shop provider to rebuild when purchases change
    ref.watch(shopProvider);

    // Get purchased roles (as GameCharacter instances)
    final purchasedRoles = ref.read(rolesProvider.notifier).getPurchasedRoles();

    // Get unpurchased roles (as PaidRoleConfig with price info)
    final unpurchasedConfigs = ref
        .read(rolesProvider.notifier)
        .getUnpurchasedRoles();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Character Shop"),
        actions: const [_CoinsButton(), SizedBox(width: 16)],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Owned roles section
            if (purchasedRoles.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Owned Characters',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              GridView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.9,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: purchasedRoles.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  final role = purchasedRoles[index];
                  return _RoleCard(role: role);
                },
              ),
              const SizedBox(height: 16),
            ],

            // Available for purchase section
            if (unpurchasedConfigs.isNotEmpty) ...[
              const Divider(),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Available for Purchase',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              GridView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.75,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: unpurchasedConfigs.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  final config = unpurchasedConfigs[index];
                  final role = config.role;
                  return _ShopRoleCard(role: role, price: config.price);
                },
              ),
              const SizedBox(height: 16),
            ],

            // Empty state
            if (purchasedRoles.isEmpty && unpurchasedConfigs.isEmpty)
              const Padding(
                padding: EdgeInsets.all(32),
                child: Center(
                  child: Text(
                    'All roles unlocked!',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _RoleCard extends ConsumerWidget {
  final GameCharacter role;

  const _RoleCard({required this.role});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Role icon/image
            Expanded(
              child: Center(
                child: FaIcon(role.icon, size: 64, color: Colors.green),
              ),
            ),
            // Role name
            Text(
              role.name,
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            // Status/Price
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'OWNED',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ShopRoleCard extends ConsumerWidget {
  final GameCharacter role;
  final int price;

  const _ShopRoleCard({required this.role, required this.price});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final coins = ref.watch(coinsProvider);
    final canAfford = coins >= price;

    return Card(
      elevation: 4,
      child: InkWell(
        onTap: () => _showPurchaseDialog(context, ref, canAfford),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Role icon/image
              Expanded(
                child: Center(
                  child: FaIcon(role.icon, size: 64, color: Colors.grey),
                ),
              ),
              // Role name
              Text(
                role.name,
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),

              // Status/Price
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: canAfford ? Colors.blue : Colors.grey,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.monetization_on,
                      size: 16,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      price.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showPurchaseDialog(
    BuildContext context,
    WidgetRef ref,
    bool canAfford,
  ) {
    final coins = ref.read(coinsProvider);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Purchase ${role.name}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Price: $price coins'),
            Text('Your coins: $coins'),
            if (!canAfford)
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: Text(
                  'Not enough coins!',
                  style: TextStyle(color: Colors.red),
                ),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          if (canAfford)
            ElevatedButton(
              onPressed: () async {
                // Purchase role using role name
                await ref
                    .read(shopProvider.notifier)
                    .purchaseRole(role.name, price);

                if (context.mounted) {
                  Navigator.pop(context);

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${role.name} purchased!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              },
              child: const Text('Purchase'),
            ),
        ],
      ),
    );
  }
}

class _CoinsButton extends ConsumerWidget {
  const _CoinsButton();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final coins = ref.watch(coinsProvider);

    return GestureDetector(
      onTap: () => _showCoinsDialog(context, ref),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.amber,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            const Icon(Icons.monetization_on, color: Colors.white),
            const SizedBox(width: 4),
            Text(
              coins == 0 ? "Free" : coins.toString(),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCoinsDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Get Free Coins"),
        content: const Text("Watch an ad to earn 50 coins!"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              final adNotifier = ref.read(adProvider.notifier);

              // Check if ad is ready before showing
              if (!adNotifier.isRewardedReady) {
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Ad not ready yet. Please try again.'),
                      backgroundColor: Colors.orange,
                    ),
                  );
                }
                return;
              }

              adNotifier.showRewarded(
                onRewardEarned: (rewardAmount) {
                  // This will ONLY be called if user watched the full ad
                  ref.read(coinsProvider.notifier).addCoins(rewardAmount);

                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('🎉 $rewardAmount coins added!'),
                        backgroundColor: Colors.green,
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  }
                },
                onDismissed: () {
                  // This is called whether or not the reward was earned
                  if (context.mounted) {
                    Navigator.pop(context);
                  }
                },
              );
            },
            child: const Text("Watch Ad"),
          ),
        ],
      ),
    );
  }
}
