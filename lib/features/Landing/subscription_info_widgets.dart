import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:loup_garou/providers/revenue_cat.dart';
import 'customer_center_screen.dart';
import 'paywall_screen.dart';

/// Subscription Info Widget
///
/// Displays the user's current subscription status and provides
/// quick access to upgrade or manage subscriptions.
class SubscriptionInfoWidget extends ConsumerWidget {
  const SubscriptionInfoWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subscriptionState = ref.watch(revenueCatServiceProvider);

    if (subscriptionState.isLoading) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  subscriptionState.hasSubscription
                      ? Icons.workspace_premium
                      : Icons.lock_outline,
                  color: subscriptionState.hasSubscription
                      ? Colors.amber
                      : Colors.grey,
                  size: 32,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        subscriptionState.hasSubscription
                            ? 'Loup Garou Pro'
                            : 'Free Version',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subscriptionState.statusText,
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Action button
            SizedBox(
              width: double.infinity,
              child: subscriptionState.hasSubscription
                  ? OutlinedButton.icon(
                      onPressed: () => presentCustomerCenter(context),
                      icon: const Icon(Icons.settings),
                      label: const Text('Manage Subscription'),
                    )
                  : ElevatedButton.icon(
                      onPressed: () => _showPaywall(context, ref),
                      icon: const Icon(Icons.upgrade),
                      label: const Text('Upgrade to Pro'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
            ),

            // Error message
            if (subscriptionState.errorMessage != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: Colors.red,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        subscriptionState.errorMessage!,
                        style: const TextStyle(color: Colors.red, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _showPaywall(BuildContext context, WidgetRef ref) async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) => const PaywallScreen(),
        fullscreenDialog: true,
      ),
    );

    // Refresh subscription state after returning
    if (result == true && context.mounted) {
      final service = ref.read(revenueCatServiceProvider.notifier);
      await service.refreshCustomerInfo();
    }
  }
}

/// Compact Subscription Badge
///
/// A small badge that can be placed in app bars or other UI elements
/// to show subscription status.
class SubscriptionBadge extends ConsumerWidget {
  final VoidCallback? onTap;

  const SubscriptionBadge({this.onTap, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subscriptionState = ref.watch(revenueCatServiceProvider);

    if (subscriptionState.isLoading) {
      return const SizedBox(
        width: 80,
        child: Center(
          child: SizedBox.square(
            dimension: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }

    return InkWell(
      onTap:
          onTap ??
          () => _handleTap(context, ref, subscriptionState.hasSubscription),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: subscriptionState.hasSubscription
              ? Colors.amber.withValues(alpha: 0.2)
              : Colors.grey.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: subscriptionState.hasSubscription
                ? Colors.amber
                : Colors.grey,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              subscriptionState.hasSubscription
                  ? Icons.workspace_premium
                  : Icons.lock_outline,
              size: 16,
              color: subscriptionState.hasSubscription
                  ? Colors.amber[700]
                  : Colors.grey[700],
            ),
            const SizedBox(width: 6),
            Text(
              subscriptionState.hasSubscription ? 'PRO' : 'FREE',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: subscriptionState.hasSubscription
                    ? Colors.amber[700]
                    : Colors.grey[700],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleTap(BuildContext context, WidgetRef ref, bool hasSubscription) {
    if (hasSubscription) {
      presentCustomerCenter(context);
    } else {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => const PaywallScreen(),
          fullscreenDialog: true,
        ),
      );
    }
  }
}

/// Pro Feature Gate Widget
///
/// Wraps content that should only be accessible to Pro users.
/// Shows a paywall prompt for free users.
class ProFeatureGate extends ConsumerWidget {
  final Widget child;
  final Widget? placeholder;
  final String featureName;

  const ProFeatureGate({
    required this.child,
    required this.featureName,
    this.placeholder,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subscriptionState = ref.watch(revenueCatServiceProvider);

    if (subscriptionState.isProUser) {
      return child;
    }

    return placeholder ?? _buildLockedPlaceholder(context, ref);
  }

  Widget _buildLockedPlaceholder(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.lock_outline, size: 48, color: Colors.grey[600]),
          const SizedBox(height: 16),
          Text(
            '$featureName is a Pro feature',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Upgrade to Loup Garou Pro to unlock this feature',
            style: TextStyle(color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => _showPaywall(context, ref),
            icon: const Icon(Icons.upgrade),
            label: const Text('Upgrade to Pro'),
          ),
        ],
      ),
    );
  }

  Future<void> _showPaywall(BuildContext context, WidgetRef ref) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const PaywallScreen(),
        fullscreenDialog: true,
      ),
    );
  }
}
