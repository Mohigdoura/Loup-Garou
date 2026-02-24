import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
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
  static const String _interstitialTestId =
      'ca-app-pub-3940256099942544/1033173712';
  static const String _rewardedTestId =
      'ca-app-pub-3940256099942544/5224354917';

  static final String _interstitialId = kDebugMode
      ? _interstitialTestId
      : dotenv.env['INTERSTITIAL_ID'] ?? _interstitialTestId;
  static final String _rewardedId = kDebugMode
      ? _rewardedTestId
      : dotenv.env['REWARDED_ID'] ?? _rewardedTestId;
  void loadInterstitial() {
    // Don't load if already loading or loaded

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
