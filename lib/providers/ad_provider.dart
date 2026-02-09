import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:loup_garou/models/ad_state.dart';

final adProvider = NotifierProvider<AdNotifier, AdState>(() => AdNotifier());

class AdNotifier extends Notifier<AdState> {
  @override
  AdState build() {
    return AdState();
  }

  // Test IDs - Replace with real ones for production
  static const String _interstitialId =
      'ca-app-pub-8471114413175146/6227692806';
  static const String _rewardedId = 'ca-app-pub-8471114413175146/1272316386';

  void loadInterstitial() {
    // Don't load if already loading or loaded
    if (kDebugMode) return;
    if (state.isInterstitialLoaded || state.interstitialAd != null) return;

    InterstitialAd.load(
      adUnitId: _interstitialId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          state = state.copyWith(
            interstitialAd: ad,
            isInterstitialLoaded: true,
          );
        },
        onAdFailedToLoad: (err) {
          state = state.copyWith(isInterstitialLoaded: false);

          // Optional: Add logging or retry logic
          log('Interstitial ad failed to load: ${err.message}');
        },
      ),
    );
  }

  void loadRewarded() {
    if (kDebugMode) return;

    // Don't load if already loading or loaded
    if (state.isRewardedLoaded || state.rewardedAd != null) return;

    RewardedAd.load(
      adUnitId: _rewardedId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          state = state.copyWith(rewardedAd: ad, isRewardedLoaded: true);
        },
        onAdFailedToLoad: (err) {
          state = state.copyWith(isRewardedLoaded: false);

          // Optional: Add logging or retry logic
          log('Rewarded ad failed to load: ${err.message}');
        },
      ),
    );
  }

  void showInterstitial(VoidCallback onDismissed) {
    final ad = state.interstitialAd;

    if (ad == null || !state.isInterstitialLoaded) {
      loadInterstitial();
      onDismissed(); // Continue even if ad fails
      return;
    }

    // Clear state immediately to prevent double-showing
    state = state.copyWith(interstitialAd: null, isInterstitialLoaded: false);

    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        loadInterstitial(); // Preload next ad
        onDismissed();
      },
      onAdFailedToShowFullScreenContent: (ad, err) {
        ad.dispose();
        loadInterstitial(); // Preload next ad
        onDismissed();
        print('Interstitial ad failed to show: ${err.message}');
      },
    );

    ad.show();
  }

  void showRewarded({
    required Function(int) onRewardEarned,
    required VoidCallback onDismissed,
  }) {
    final ad = state.rewardedAd;

    if (ad == null || !state.isRewardedLoaded) {
      loadRewarded();
      onDismissed();
      return;
    }

    // Clear state immediately to prevent double-showing
    state = state.copyWith(rewardedAd: null, isRewardedLoaded: false);

    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        loadRewarded(); // Preload next ad
        onDismissed(); // Dismiss without reward
        print('Rewarded ad failed to show: ${error.message}');
      },
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        loadRewarded(); // Preload next ad

        // Always call dismissed callback
        onDismissed();
      },
    );

    // Show the ad and set reward callback
    ad.show(
      onUserEarnedReward: (ad, reward) {
        onRewardEarned(50);

        print('User earned reward: ${reward.amount} ${reward.type}');
      },
    );
  }

  // Helper method to check ad availability
  bool get isInterstitialReady =>
      state.isInterstitialLoaded && state.interstitialAd != null;
  bool get isRewardedReady =>
      state.isRewardedLoaded && state.rewardedAd != null;
}
