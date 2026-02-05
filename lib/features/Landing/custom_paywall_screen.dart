import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:loup_garou/providers/revenue_cat.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

/// Custom Paywall Screen
///
/// This is a custom-designed paywall that you can use if you prefer
/// more control over the design, or as a fallback if RevenueCat Paywalls
/// are not configured.
class CustomPaywallScreen extends ConsumerWidget {
  const CustomPaywallScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subscriptionState = ref.watch(revenueCatServiceProvider);
    final service = ref.read(revenueCatServiceProvider.notifier);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(context),

            // Content
            Expanded(
              child: subscriptionState.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : subscriptionState.offerings == null
                  ? _buildErrorState(context)
                  : _buildOfferingsList(
                      context,
                      ref,
                      subscriptionState.offerings!,
                      service,
                    ),
            ),

            // Footer with restore button
            _buildFooter(context, ref, service),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.of(context).pop(),
          ),
          const Spacer(),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            'Unable to load subscriptions',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          const Text('Please check your connection and try again'),
        ],
      ),
    );
  }

  Widget _buildOfferingsList(
    BuildContext context,
    WidgetRef ref,
    Offerings offerings,
    RevenueCatService service,
  ) {
    final currentOffering = offerings.current;

    if (currentOffering == null || currentOffering.availablePackages.isEmpty) {
      return const Center(child: Text('No subscription options available'));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Hero section
          Text(
            'Unlock Loup Garou Pro',
            style: Theme.of(
              context,
            ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),

          // Features list
          _buildFeaturesList(),
          const SizedBox(height: 32),

          // Subscription packages
          ...currentOffering.availablePackages.map(
            (package) => _buildPackageCard(context, ref, package, service),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturesList() {
    final features = [
      'Remove all advertisements',
      'Unlimited game modes',
      'Custom character packs',
      'Priority customer support',
      'Exclusive content updates',
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: features
              .map(
                (feature) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle, color: Colors.green),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          feature,
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                ),
              )
              .toList(),
        ),
      ),
    );
  }

  Widget _buildPackageCard(
    BuildContext context,
    WidgetRef ref,
    Package package,
    RevenueCatService service,
  ) {
    final subscriptionState = ref.watch(revenueCatServiceProvider);
    // final isMonthly = package.identifier == '\$rc_monthly';
    final isYearly = package.identifier == '\$rc_annual';

    // Calculate savings for annual plan
    String? savingsText;
    if (isYearly) {
      final offerings = subscriptionState.offerings;
      final monthlyPackage = offerings?.current?.monthly;
      if (monthlyPackage != null) {
        final monthlyPrice = monthlyPackage.storeProduct.price;
        final yearlyPrice = package.storeProduct.price;
        final monthlyCostOfYearly = yearlyPrice / 12;
        final savingsPercent =
            ((monthlyPrice - monthlyCostOfYearly) / monthlyPrice * 100).round();
        if (savingsPercent > 0) {
          savingsText = 'Save $savingsPercent%';
        }
      }
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: isYearly
            ? const BorderSide(color: Colors.blue, width: 2)
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: subscriptionState.isLoading
            ? null
            : () => _handlePurchase(context, ref, package, service),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              package.storeProduct.title,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (savingsText != null) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.green,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  savingsText,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          package.storeProduct.description,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        package.storeProduct.priceString,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                      if (isYearly && package.storeProduct.price > 0) ...[
                        Text(
                          '${package.storeProduct.currencyCode} ${(package.storeProduct.price / 12).toStringAsFixed(2)}/mo',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
              if (isYearly) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.star, color: Colors.blue, size: 16),
                      SizedBox(width: 4),
                      Text(
                        'Best Value',
                        style: TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handlePurchase(
    BuildContext context,
    WidgetRef ref,
    Package package,
    RevenueCatService service,
  ) async {
    final success = await service.purchasePackage(package);

    if (!context.mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('🎉 Welcome to Loup Garou Pro!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.of(context).pop(true);
    } else {
      final error = ref.read(revenueCatServiceProvider).errorMessage;
      if (error != null && !error.contains('cancelled')) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error), backgroundColor: Colors.red),
        );
      }
    }
  }

  Widget _buildFooter(
    BuildContext context,
    WidgetRef ref,
    RevenueCatService service,
  ) {
    final subscriptionState = ref.watch(revenueCatServiceProvider);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        border: Border(top: BorderSide(color: Colors.grey[300]!)),
      ),
      child: Column(
        children: [
          TextButton(
            onPressed: subscriptionState.isLoading
                ? null
                : () => _handleRestore(context, ref, service),
            child: const Text('Restore Purchases'),
          ),
          const SizedBox(height: 8),
          Text(
            'Subscriptions auto-renew. Cancel anytime.',
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Future<void> _handleRestore(
    BuildContext context,
    WidgetRef ref,
    RevenueCatService service,
  ) async {
    final success = await service.restorePurchases();

    if (!context.mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Purchases restored successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.of(context).pop(true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No purchases found to restore'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }
}
