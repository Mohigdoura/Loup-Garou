import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:loup_garou/features/shop/providers/coins_provider.dart';
import 'package:loup_garou/features/shop/providers/shop_provider.dart';
import 'package:loup_garou/l10n/app_localizations.dart';
import 'package:loup_garou/models/game_character.dart';

class RoleCard extends ConsumerWidget {
  final GameCharacter role;
  final int price;

  const RoleCard({super.key, required this.role, required this.price});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
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
          onTap: () => _showBuyDialog(context, ref, canAfford, l10n),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                _buildRoleIcon(),
                const SizedBox(width: 16),
                Expanded(child: _buildRoleInfo(l10n)),
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

  Widget _buildRoleInfo(AppLocalizations l10n) {
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
          l10n.roleCardTapHint,
          style: TextStyle(
            fontSize: 12,
            color: Colors.white.withValues(alpha: 0.5),
          ),
        ),
      ],
    );
  }

  void _showBuyDialog(
    BuildContext context,
    WidgetRef ref,
    bool canAfford,
    AppLocalizations l10n,
  ) {
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
            Text(
              l10n.roleCardAbilityLabel,
              style: const TextStyle(
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
            child: Text(
              l10n.close,
              style: const TextStyle(fontWeight: FontWeight.bold),
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
                              Text(l10n.rolePurchased(role.name)),
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
            child: Text(
              l10n.buy,
              style: const TextStyle(fontWeight: FontWeight.bold),
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
