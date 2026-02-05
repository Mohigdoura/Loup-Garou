import 'package:purchases_flutter/purchases_flutter.dart';

/// Represents the current subscription state of the user
class SubscriptionState {
  final bool isProUser;
  final bool isLoading;
  final CustomerInfo? customerInfo;
  final Offerings? offerings;
  final String? errorMessage;
  final bool hasActiveSubscription;
  final String? activeProductId;
  final DateTime? expirationDate;
  final bool willRenew;

  const SubscriptionState({
    this.isProUser = false,
    this.isLoading = false,
    this.customerInfo,
    this.offerings,
    this.errorMessage,
    this.hasActiveSubscription = false,
    this.activeProductId,
    this.expirationDate,
    this.willRenew = false,
  });

  /// Check if user has any active subscription
  bool get hasSubscription => isProUser || hasActiveSubscription;

  /// Get subscription status text
  String get statusText {
    if (isProUser) {
      if (willRenew) {
        return 'Active - Renews ${_formatDate(expirationDate)}';
      } else {
        return 'Active - Expires ${_formatDate(expirationDate)}';
      }
    }
    return 'No active subscription';
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Unknown';
    return '${date.month}/${date.day}/${date.year}';
  }

  /// Create a copy with updated fields
  SubscriptionState copyWith({
    bool? isProUser,
    bool? isLoading,
    CustomerInfo? customerInfo,
    Offerings? offerings,
    String? errorMessage,
    bool? hasActiveSubscription,
    String? activeProductId,
    DateTime? expirationDate,
    bool? willRenew,
  }) {
    return SubscriptionState(
      isProUser: isProUser ?? this.isProUser,
      isLoading: isLoading ?? this.isLoading,
      customerInfo: customerInfo ?? this.customerInfo,
      offerings: offerings ?? this.offerings,
      errorMessage: errorMessage,
      hasActiveSubscription:
          hasActiveSubscription ?? this.hasActiveSubscription,
      activeProductId: activeProductId ?? this.activeProductId,
      expirationDate: expirationDate ?? this.expirationDate,
      willRenew: willRenew ?? this.willRenew,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SubscriptionState &&
        other.isProUser == isProUser &&
        other.isLoading == isLoading &&
        other.customerInfo == customerInfo &&
        other.offerings == offerings &&
        other.errorMessage == errorMessage &&
        other.hasActiveSubscription == hasActiveSubscription &&
        other.activeProductId == activeProductId &&
        other.expirationDate == expirationDate &&
        other.willRenew == willRenew;
  }

  @override
  int get hashCode {
    return Object.hash(
      isProUser,
      isLoading,
      customerInfo,
      offerings,
      errorMessage,
      hasActiveSubscription,
      activeProductId,
      expirationDate,
      willRenew,
    );
  }
}
