import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:loup_garou/models/subscription_state.dart';
import 'package:loup_garou/providers/revenue_cat.dart';
import 'package:purchases_ui_flutter/purchases_ui_flutter.dart';

/// Customer Center Screen
///
/// This screen allows users to manage their subscriptions using
/// RevenueCat's Customer Center feature.
///
/// Features:
/// - Cancel subscriptions
/// - Request refunds (iOS only)
/// - Change subscription plans (iOS only)
/// - Restore purchases
/// - Contact support
class CustomerCenterScreen extends ConsumerStatefulWidget {
  const CustomerCenterScreen({super.key});

  @override
  ConsumerState<CustomerCenterScreen> createState() =>
      _CustomerCenterScreenState();
}

class _CustomerCenterScreenState extends ConsumerState<CustomerCenterScreen> {
  bool _isPresenting = false;

  @override
  void initState() {
    super.initState();
    // Present Customer Center after frame is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _presentCustomerCenter();
    });
  }

  /// Present RevenueCat Customer Center
  Future<void> _presentCustomerCenter() async {
    if (_isPresenting) return;

    setState(() {
      _isPresenting = true;
    });

    try {
      // Present Customer Center
      await RevenueCatUI.presentCustomerCenter();

      // Refresh customer info after Customer Center is dismissed
      final service = ref.read(revenueCatServiceProvider.notifier);
      await service.refreshCustomerInfo();

      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      debugPrint('Error presenting Customer Center: $e');
      _showError('Failed to load Customer Center: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() {
          _isPresenting = false;
        });
      }
    }
  }

  void _showError(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 24),
            Text(
              'Loading subscription management...',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
      ),
    );
  }
}

/// Custom Customer Center Screen (Fallback)
///
/// This is a custom implementation for managing subscriptions
/// if RevenueCat Customer Center is not available or not configured.
class CustomCustomerCenterScreen extends ConsumerWidget {
  const CustomCustomerCenterScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subscriptionState = ref.watch(revenueCatServiceProvider);
    final service = ref.read(revenueCatServiceProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Manage Subscription'), elevation: 0),
      body: subscriptionState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Subscription status card
                  _buildStatusCard(context, subscriptionState),
                  const SizedBox(height: 24),

                  // Management options
                  if (subscriptionState.hasSubscription) ...[
                    _buildManagementSection(context, ref, subscriptionState),
                    const SizedBox(height: 24),
                  ],

                  // Support section
                  _buildSupportSection(context, service),
                ],
              ),
            ),
    );
  }

  Widget _buildStatusCard(BuildContext context, SubscriptionState state) {
    final bool isActive = state.hasSubscription;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  isActive ? Icons.check_circle : Icons.info_outline,
                  color: isActive ? Colors.green : Colors.orange,
                  size: 32,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isActive ? 'Loup Garou Pro' : 'Free Version',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        state.statusText,
                        style: TextStyle(color: Colors.grey[600], fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (state.activeProductId != null) ...[
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 16),
              _buildInfoRow('Plan', _formatProductId(state.activeProductId!)),
              const SizedBox(height: 8),
              if (state.expirationDate != null)
                _buildInfoRow(
                  state.willRenew ? 'Renews on' : 'Expires on',
                  _formatDate(state.expirationDate!),
                ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 14, color: Colors.grey)),
        Text(
          value,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  Widget _buildManagementSection(
    BuildContext context,
    WidgetRef ref,
    SubscriptionState state,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Subscription Management',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 16),

        // Manage via store
        _buildOptionCard(
          context,
          icon: Icons.settings,
          title: 'Manage via ${Platform.isIOS ? 'App Store' : 'Google Play'}',
          subtitle: 'Change plan, cancel, or view billing',
          onTap: () => _openStoreManagement(context),
        ),

        const SizedBox(height: 12),

        // Restore purchases
        _buildOptionCard(
          context,
          icon: Icons.refresh,
          title: 'Restore Purchases',
          subtitle: 'Recover your subscription on this device',
          onTap: () => _handleRestore(context, ref),
        ),
      ],
    );
  }

  Widget _buildSupportSection(BuildContext context, RevenueCatService service) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Support', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 16),

        _buildOptionCard(
          context,
          icon: Icons.help_outline,
          title: 'Help & FAQ',
          subtitle: 'Get answers to common questions',
          onTap: () => _openHelp(context),
        ),

        const SizedBox(height: 12),

        _buildOptionCard(
          context,
          icon: Icons.email_outlined,
          title: 'Contact Support',
          subtitle: 'Get help from our team',
          onTap: () => _contactSupport(context),
        ),

        // Customer ID for support
        const SizedBox(height: 24),
        Card(
          color: Colors.grey[100],
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Customer ID',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  service.getCustomerId() ?? 'Not available',
                  style: const TextStyle(fontSize: 14, fontFamily: 'monospace'),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Include this ID when contacting support',
                  style: TextStyle(fontSize: 11, color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOptionCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(icon, color: Theme.of(context).primaryColor),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  void _openStoreManagement(BuildContext context) {
    // In a real app, you would open the platform-specific subscription management
    // For iOS: https://apps.apple.com/account/subscriptions
    // For Android: https://play.google.com/store/account/subscriptions

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Manage Subscription'),
        content: Text(
          Platform.isIOS
              ? 'Go to Settings > [Your Name] > Subscriptions on your device to manage your subscription.'
              : 'Go to Google Play Store > Menu > Subscriptions to manage your subscription.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _handleRestore(BuildContext context, WidgetRef ref) async {
    final service = ref.read(revenueCatServiceProvider.notifier);
    final success = await service.restorePurchases();

    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? '✅ Purchases restored successfully!'
              : 'No purchases found to restore',
        ),
        backgroundColor: success ? Colors.green : Colors.orange,
      ),
    );
  }

  void _openHelp(BuildContext context) {
    // Navigate to help/FAQ screen or open web page
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Help & FAQ'),
        content: const Text(
          'This would open your help documentation or FAQ page.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _contactSupport(BuildContext context) {
    // Open email client or support form
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Contact Support'),
        content: const Text(
          'Email: support@loupgaroupro.com\n\nThis would open your email client.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  String _formatProductId(String productId) {
    if (productId.toLowerCase().contains('month')) {
      return 'Monthly';
    } else if (productId.toLowerCase().contains('year') ||
        productId.toLowerCase().contains('annual')) {
      return 'Yearly';
    }
    return productId;
  }

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}/${date.year}';
  }
}

/// Helper function to present Customer Center
Future<void> presentCustomerCenter(BuildContext context) async {
  await Navigator.of(context).push(
    MaterialPageRoute(
      builder: (context) => const CustomerCenterScreen(),
      fullscreenDialog: true,
    ),
  );
}
