import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:loup_garou/providers/revenue_cat.dart';
import 'package:purchases_ui_flutter/purchases_ui_flutter.dart';

/// Paywall Screen using RevenueCat Paywalls
///
/// This screen presents a remotely configured paywall using RevenueCat's
/// Paywall feature. The paywall design is managed in the RevenueCat dashboard.
class PaywallScreen extends ConsumerStatefulWidget {
  const PaywallScreen({super.key});

  @override
  ConsumerState<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends ConsumerState<PaywallScreen> {
  bool _isPresenting = false;

  @override
  void initState() {
    super.initState();
    // Present paywall after frame is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _presentPaywall();
    });
  }

  /// Present RevenueCat Paywall
  Future<void> _presentPaywall() async {
    if (_isPresenting) return;

    setState(() {
      _isPresenting = true;
    });

    try {
      final service = ref.read(revenueCatServiceProvider.notifier);
      final offering = service.getCurrentOffering();

      if (offering == null) {
        _showError('No offerings available. Please try again later.');
        return;
      }

      // Present the paywall
      final paywallResult = await RevenueCatUI.presentPaywall();

      debugPrint('Paywall result: $paywallResult');

      // Handle the result
      if (paywallResult == PaywallResult.purchased ||
          paywallResult == PaywallResult.restored) {
        // Refresh customer info
        await service.refreshCustomerInfo();

        if (mounted) {
          // Show success and pop
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                paywallResult == PaywallResult.purchased
                    ? '🎉 Welcome to Loup Garou Pro!'
                    : '✅ Purchases restored successfully!',
              ),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.of(context).pop(true);
        }
      } else if (paywallResult == PaywallResult.cancelled) {
        // User cancelled
        if (mounted) {
          Navigator.of(context).pop(false);
        }
      }
    } catch (e) {
      debugPrint('Error presenting paywall: $e');
      _showError('Failed to load paywall: ${e.toString()}');
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
    Navigator.of(context).pop(false);
  }

  @override
  Widget build(BuildContext context) {
    // Show loading indicator while presenting
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 24),
            Text(
              'Loading subscription options...',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
      ),
    );
  }
}

/// Alternative: Present paywall as a bottom sheet
/// This can be used instead of the full screen approach
Future<bool?> showPaywallBottomSheet(BuildContext context) async {
  try {
    final paywallResult = await RevenueCatUI.presentPaywallIfNeeded(
      'Loup Garou Pro',
    );

    return paywallResult == PaywallResult.purchased ||
        paywallResult == PaywallResult.restored;
  } catch (e) {
    debugPrint('Error presenting paywall: $e');
    return false;
  }
}

/// Present paywall only if user doesn't have entitlement
Future<bool> presentPaywallIfNeeded(BuildContext context, WidgetRef ref) async {
  final service = ref.read(revenueCatServiceProvider.notifier);

  // Check if user already has Pro
  if (service.hasProEntitlement()) {
    return true;
  }

  // Present paywall
  final result = await Navigator.of(context).push<bool>(
    MaterialPageRoute(
      builder: (context) => const PaywallScreen(),
      fullscreenDialog: true,
    ),
  );

  return result ?? false;
}
