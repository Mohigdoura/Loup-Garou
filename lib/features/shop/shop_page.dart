import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:loup_garou/features/shop/providers/shop_provider.dart';
import 'package:loup_garou/models/game_character.dart';
import 'package:loup_garou/providers/ad_provider.dart';
import 'package:loup_garou/features/shop/providers/coins_provider.dart';
import 'package:loup_garou/features/setup/providers/roles_provider.dart';

// Cached decorations for better performance
const _kBackgroundGradient = BoxDecoration(
  gradient: LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF0a0e27), Color(0xFF1a1f3a), Color(0xFF2d1b3d)],
  ),
);

class ShopPage extends ConsumerStatefulWidget {
  const ShopPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ShopPageState();
}

String _adminCode = 'sayib el l3b';

class _ShopPageState extends ConsumerState<ShopPage> {
  @override
  void initState() {
    super.initState();
    ref.read(adProvider.notifier).loadRewarded();
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(shopProvider);
    final unpurchasedConfigs = ref
        .read(rolesProvider.notifier)
        .getUnpurchasedRoles();
    unpurchasedConfigs.sort((a, b) => a.price.compareTo(b.price));

    return Scaffold(
      body: SafeArea(
        child: Container(
          decoration: _kBackgroundGradient,
          child: Column(
            children: [
              _buildHeader(context),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    children: [
                      const SizedBox(height: 8),

                      // Available for purchase section
                      if (unpurchasedConfigs.isNotEmpty) ...[
                        _buildSectionHeader(
                          'Available Characters',
                          Icons.shopping_bag,
                        ),
                        ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: unpurchasedConfigs.length,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemBuilder: (context, index) {
                            final config = unpurchasedConfigs[index];
                            final role = config.role;
                            return RepaintBoundary(
                              child: RoleCard(role: role, price: config.price),
                            );
                          },
                        ),
                        const SizedBox(height: 24),
                      ],

                      // Empty state
                      if (unpurchasedConfigs.isEmpty) _buildEmptyState(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.black.withValues(alpha: 0.3), Colors.transparent],
        ),
      ),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Color(0xFFd4af37)),
              onPressed: () => context.pop(),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Character Shop',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFd4af37),
                    letterSpacing: 0.5,
                  ),
                ),
                Text(
                  'Unlock new roles',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onLongPress: () => _showAdminDialog(context, ref),
            child: const _CoinsButton(),
          ),
        ],
      ),
    );
  }

  void _showAdminDialog(BuildContext context, WidgetRef ref) {
    final codeController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1a1f3a),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Color(0xFFd4af37), width: 2),
        ),
        title: const Row(
          children: [
            Icon(Icons.lock_open, color: Color(0xFFd4af37)),
            SizedBox(width: 12),
            Text(
              'Admin Access',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: TextField(
          controller: codeController,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Enter code',
            hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.5)),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: Color(0xFFd4af37).withValues(alpha: 0.5),
              ),
            ),
            focusedBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Color(0xFFd4af37)),
            ),
          ),
          obscureText: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(foregroundColor: Colors.white70),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final enteredCode = codeController.text.trim();
              if (enteredCode == _adminCode) {
                // Unlock all paid roles
                final allPaidRoleNames = ref
                    .read(rolesProvider.notifier)
                    .getAllPaidRoleNames();
                ref
                    .read(shopProvider.notifier)
                    .unlockAllRoles(allPaidRoleNames);

                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.white),
                        SizedBox(width: 8),
                        Text('All roles unlocked!'),
                      ],
                    ),
                    backgroundColor: Colors.green,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              } else {
                // Wrong code
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Row(
                      children: [
                        Icon(Icons.error, color: Colors.white),
                        SizedBox(width: 8),
                        Text('Invalid code'),
                      ],
                    ),
                    backgroundColor: Colors.red,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFd4af37),
              foregroundColor: Colors.black,
            ),
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFd4af37).withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: const Color(0xFFd4af37), size: 20),
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.all(48),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFFd4af37).withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.stars, size: 64, color: Color(0xFFd4af37)),
          ),
          const SizedBox(height: 24),
          const Text(
            'All Characters Unlocked!',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'You own every character in the game',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }
}

class OwnedRoleCard extends ConsumerWidget {
  final GameCharacter role;

  const OwnedRoleCard({super.key, required this.role});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.green.shade800.withValues(alpha: 0.4),
        border: Border.all(
          color: Colors.green.withValues(alpha: 0.5),
          width: 2,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Role icon/image
            Container(
              width: 72,
              height: 72,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: role.image != null && role.image!.isNotEmpty
                  ? Image.asset(
                      role.image!,
                      color: role.imageColor ?? Colors.green,
                      fit: BoxFit.contain,
                    )
                  : FaIcon(role.icon, size: 48, color: Colors.green.shade300),
            ),
            const SizedBox(height: 12),

            // Role name
            Text(
              role.name,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const Spacer(),

            // Owned badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.check, color: Colors.white, size: 16),
                  SizedBox(width: 4),
                  Text(
                    'OWNED',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class RoleCard extends ConsumerWidget {
  final GameCharacter role;
  final int price;

  const RoleCard({super.key, required this.role, required this.price});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final coins = ref.watch(coinsProvider);
    final canAfford = coins >= price;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: const Color(0xFF1a1f3a).withValues(alpha: 0.6),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showBuyDialog(context, ref, canAfford),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                _buildRoleIcon(),
                const SizedBox(width: 16),
                Expanded(child: _buildRoleInfo()),
                const SizedBox(width: 12),
                _buildBuyButton(canAfford),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRoleIcon() {
    final color = Colors.blue.shade300;

    return Container(
      width: 64,
      height: 64,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.4), width: 1.5),
      ),
      child: role.image != null && role.image!.isNotEmpty
          ? Image.asset(
              role.image!,
              color: role.imageColor,
              fit: BoxFit.contain,
            )
          : FaIcon(role.icon, color: color, size: 36),
    );
  }

  Widget _buildRoleInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          role.name,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Tap to view abilities',
          style: TextStyle(
            fontSize: 12,
            color: Colors.white.withValues(alpha: 0.5),
          ),
        ),
      ],
    );
  }

  void _showBuyDialog(BuildContext context, WidgetRef ref, bool canAfford) {
    final teamColor = Colors.blue.shade600;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1a1f3a),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: teamColor.withValues(alpha: 0.5), width: 2),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: teamColor.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: role.image != null && role.image!.isNotEmpty
                  ? Image.asset(
                      role.image!,
                      width: 24,
                      height: 24,
                      color: role.imageColor,
                    )
                  : FaIcon(role.icon, color: teamColor, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                role.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Ability',
              style: TextStyle(
                color: Color(0xFFd4af37),
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              role.ability,
              style: const TextStyle(color: Colors.white70, height: 1.5),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFFd4af37),
            ),
            child: const Text(
              "Close",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          TextButton(
            onPressed: canAfford
                ? () async {
                    context.pop();

                    await ref
                        .read(shopProvider.notifier)
                        .purchaseRole(role.name, price);

                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Row(
                            children: [
                              const Icon(
                                Icons.check_circle,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 8),
                              Text('${role.name} purchased!'),
                            ],
                          ),
                          backgroundColor: Colors.green,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      );
                    }
                  }
                : null,
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFFd4af37),
            ),
            child: const Text(
              "Buy",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBuyButton(bool canAfford) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        gradient: canAfford
            ? const LinearGradient(
                colors: [Color(0xFFd4af37), Color(0xFFf4d03f)],
              )
            : null,
        color: canAfford ? null : Colors.grey.shade800,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.monetization_on,
            color: canAfford ? Colors.black : Colors.grey,
            size: 20,
          ),
          const SizedBox(width: 6),
          Text(
            price.toString(),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: canAfford ? Colors.black : Colors.grey,
            ),
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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFd4af37), Color(0xFFf4d03f)],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFd4af37).withValues(alpha: 0.4),
              blurRadius: 8,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Row(
          children: [
            const Icon(Icons.monetization_on, color: Colors.black, size: 20),
            const SizedBox(width: 6),
            Text(
              coins.toString(),
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.add_circle, color: Colors.black, size: 16),
          ],
        ),
      ),
    );
  }

  void _showCoinsDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1a1f3a),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Color(0xFFd4af37), width: 2),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFd4af37).withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.monetization_on,
                color: Color(0xFFd4af37),
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              "Earn Free Coins",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.play_circle_filled,
                    color: Color(0xFFd4af37),
                    size: 32,
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Watch a short ad',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Earn coins instantly',
                          style: TextStyle(color: Colors.white70, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            style: TextButton.styleFrom(foregroundColor: Colors.white70),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              if (kDebugMode) {
                ref.read(coinsProvider.notifier).addCoins(500);
                return;
              }
              final adNotifier = ref.read(adProvider.notifier);

              if (!adNotifier.isRewardedReady) {
                if (context.mounted) {
                  context.pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Row(
                        children: [
                          Icon(Icons.info, color: Colors.white),
                          SizedBox(width: 8),
                          Text('Ad not ready yet. Please try again.'),
                        ],
                      ),
                      backgroundColor: Colors.orange,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  );
                }
                return;
              }

              adNotifier.showRewarded(
                onRewardEarned: (reward) {
                  ref.read(coinsProvider.notifier).addCoins(reward);

                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Row(
                          children: [
                            const Icon(Icons.celebration, color: Colors.white),
                            const SizedBox(width: 8),
                            Text('🎉 $reward coins added!'),
                          ],
                        ),
                        backgroundColor: Colors.green,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  }
                },
                onDismissed: () {
                  if (context.mounted) {
                    context.pop();
                  }
                },
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFd4af37),
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.play_arrow, size: 20),
                SizedBox(width: 4),
                Text("Watch Ad", style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
