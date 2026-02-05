import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import '../models/subscription_state.dart';

/// RevenueCat Configuration
///
/// This file contains the configuration for RevenueCat SDK.
/// IMPORTANT: Use different API keys for iOS and Android.

class RevenueCatConfig {
  // Your API key - replace with actual keys from RevenueCat dashboard
  // Found in: RevenueCat Dashboard -> Project Settings -> API keys -> App specific keys
  static const String apiKey = 'test_KPPJWwStgoecjXyImFaHBHroaNy';

  // Entitlement identifier - this should match your RevenueCat dashboard
  static const String proEntitlementId = 'Loup Garou Pro';

  // Product identifiers - these should match your store products
  static const String monthlyProductId = 'monthly';
  static const String yearlyProductId = 'yearly';

  // Offering identifier (optional, uses default if null)
  static const String? defaultOfferingId = null;

  // Enable debug logging
  static const bool enableDebugLogging = true;
}

/// Provider for RevenueCatService
final revenueCatServiceProvider =
    NotifierProvider<RevenueCatService, SubscriptionState>(
      () => RevenueCatService(),
    );

/// RevenueCat Service - Manages all subscription and purchase operations
class RevenueCatService extends Notifier<SubscriptionState> {
  @override
  SubscriptionState build() {
    _initializeRevenueCat();
    return SubscriptionState(isLoading: true);
  }

  /// Initialize RevenueCat SDK
  Future<void> _initializeRevenueCat() async {
    try {
      // Enable debug logs
      if (RevenueCatConfig.enableDebugLogging) {
        await Purchases.setLogLevel(LogLevel.debug);
      }

      // Configure SDK with API key
      PurchasesConfiguration configuration;

      if (Platform.isIOS || Platform.isMacOS) {
        configuration = PurchasesConfiguration(RevenueCatConfig.apiKey);
      } else if (Platform.isAndroid) {
        configuration = PurchasesConfiguration(RevenueCatConfig.apiKey);
      } else {
        throw PlatformException(
          code: 'UNSUPPORTED_PLATFORM',
          message: 'Platform not supported',
        );
      }

      await Purchases.configure(configuration);

      // Listen to customer info updates
      _setupCustomerInfoListener();

      // Get initial customer info and offerings
      await Future.wait([_updateCustomerInfo(), _loadOfferings()]);

      debugPrint('✅ RevenueCat initialized successfully');
    } catch (e, stackTrace) {
      debugPrint('❌ RevenueCat initialization failed: $e');
      debugPrint('Stack trace: $stackTrace');
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to initialize: ${e.toString()}',
      );
    }
  }

  /// Set up listener for customer info changes
  void _setupCustomerInfoListener() {
    Purchases.addCustomerInfoUpdateListener((customerInfo) {
      debugPrint('📱 Customer info updated');
      _processCustomerInfo(customerInfo);
    });
  }

  /// Load available offerings from RevenueCat
  Future<void> _loadOfferings() async {
    try {
      final offerings = await Purchases.getOfferings();
      state = state.copyWith(offerings: offerings);
      debugPrint('📦 Loaded ${offerings.all.length} offerings');

      // Log available packages
      final currentOffering = offerings.current;
      if (currentOffering != null) {
        debugPrint('Current offering: ${currentOffering.identifier}');
        for (final package in currentOffering.availablePackages) {
          debugPrint(
            '  - ${package.identifier}: ${package.storeProduct.priceString}',
          );
        }
      }
    } catch (e) {
      debugPrint('❌ Failed to load offerings: $e');
      state = state.copyWith(
        errorMessage: 'Failed to load offerings: ${e.toString()}',
      );
    }
  }

  /// Update customer info
  Future<void> _updateCustomerInfo() async {
    try {
      final customerInfo = await Purchases.getCustomerInfo();
      _processCustomerInfo(customerInfo);
    } catch (e) {
      debugPrint('❌ Failed to get customer info: $e');
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to get customer info: ${e.toString()}',
      );
    }
  }

  /// Process customer info and update state
  void _processCustomerInfo(CustomerInfo customerInfo) {
    // Check if user has Pro entitlement
    final hasProEntitlement = customerInfo.entitlements.active.containsKey(
      RevenueCatConfig.proEntitlementId,
    );

    // Get active entitlement info
    EntitlementInfo? proEntitlement;
    String? activeProductId;
    DateTime? expirationDate;
    bool willRenew = false;

    if (hasProEntitlement) {
      proEntitlement =
          customerInfo.entitlements.active[RevenueCatConfig.proEntitlementId];
      activeProductId = proEntitlement?.productIdentifier;
      expirationDate = proEntitlement?.expirationDate != null
          ? DateTime.parse(proEntitlement!.expirationDate!)
          : null;
      willRenew = proEntitlement?.willRenew ?? false;
    }

    // Check for any active subscriptions
    final hasActiveSubscription = customerInfo.activeSubscriptions.isNotEmpty;

    state = state.copyWith(
      isProUser: hasProEntitlement,
      isLoading: false,
      customerInfo: customerInfo,
      hasActiveSubscription: hasActiveSubscription,
      activeProductId: activeProductId,
      expirationDate: expirationDate,
      willRenew: willRenew,
      errorMessage: null,
    );

    debugPrint('👤 User is Pro: $hasProEntitlement');
    debugPrint(
      '📊 Active subscriptions: ${customerInfo.activeSubscriptions.join(", ")}',
    );
  }

  /// Purchase a package
  Future<bool> purchasePackage(Package package) async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);

      debugPrint('🛒 Attempting to purchase: ${package.identifier}');

      final purchaserInfo = await Purchases.purchase(
        PurchaseParams.package(package),
      );

      // Process the updated customer info
      _processCustomerInfo(purchaserInfo.customerInfo);

      // Check if purchase was successful
      final hasEntitlement = purchaserInfo.customerInfo.entitlements.active
          .containsKey(RevenueCatConfig.proEntitlementId);

      if (hasEntitlement) {
        debugPrint('✅ Purchase successful!');
        return true;
      } else {
        debugPrint('⚠️ Purchase completed but entitlement not active');
        return false;
      }
    } on PlatformException catch (e) {
      final errorCode = PurchasesErrorHelper.getErrorCode(e);
      String errorMessage;

      switch (errorCode) {
        case PurchasesErrorCode.purchaseCancelledError:
          errorMessage = 'Purchase was cancelled';
          debugPrint('ℹ️ Purchase cancelled by user');
          break;
        case PurchasesErrorCode.purchaseNotAllowedError:
          errorMessage = 'Purchase not allowed';
          break;
        case PurchasesErrorCode.purchaseInvalidError:
          errorMessage = 'Purchase invalid';
          break;
        default:
          errorMessage = 'Purchase failed: ${e.message}';
          debugPrint('❌ Purchase error: ${e.message}');
      }

      state = state.copyWith(isLoading: false, errorMessage: errorMessage);
      return false;
    } catch (e) {
      debugPrint('❌ Unexpected purchase error: $e');
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Unexpected error: ${e.toString()}',
      );
      return false;
    }
  }

  /// Restore purchases
  Future<bool> restorePurchases() async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);

      debugPrint('🔄 Restoring purchases...');

      final customerInfo = await Purchases.restorePurchases();
      _processCustomerInfo(customerInfo);

      final hasEntitlement = customerInfo.entitlements.active.containsKey(
        RevenueCatConfig.proEntitlementId,
      );

      if (hasEntitlement) {
        debugPrint('✅ Purchases restored successfully!');
        return true;
      } else {
        debugPrint('ℹ️ No purchases to restore');
        state = state.copyWith(errorMessage: 'No purchases found to restore');
        return false;
      }
    } catch (e) {
      debugPrint('❌ Failed to restore purchases: $e');
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to restore purchases: ${e.toString()}',
      );
      return false;
    }
  }

  /// Check if user has Pro entitlement
  bool hasProEntitlement() {
    return state.isProUser;
  }

  /// Get customer ID
  String? getCustomerId() {
    return state.customerInfo?.originalAppUserId;
  }

  /// Manually refresh customer info
  Future<void> refreshCustomerInfo() async {
    await _updateCustomerInfo();
  }

  /// Get the current offering
  Offering? getCurrentOffering() {
    return state.offerings?.current;
  }

  /// Get a specific package by identifier
  Package? getPackage(String identifier) {
    final offering = getCurrentOffering();
    if (offering == null) return null;

    try {
      return offering.availablePackages.firstWhere(
        (package) => package.identifier == identifier,
      );
    } catch (e) {
      return null;
    }
  }

  /// Get monthly package
  Package? getMonthlyPackage() {
    return getCurrentOffering()?.monthly;
  }

  /// Get annual package
  Package? getAnnualPackage() {
    return getCurrentOffering()?.annual;
  }

  /// Clear error message
  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}
