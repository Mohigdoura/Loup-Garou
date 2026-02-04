import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdState {
  final InterstitialAd? interstitialAd;
  final RewardedAd? rewardedAd;
  final bool isInterstitialLoaded;
  final bool isRewardedLoaded;

  AdState({
    this.interstitialAd,
    this.rewardedAd,
    this.isInterstitialLoaded = false,
    this.isRewardedLoaded = false,
  });

  AdState copyWith({
    InterstitialAd? interstitialAd,
    RewardedAd? rewardedAd,
    bool? isInterstitialLoaded,
    bool? isRewardedLoaded,
  }) {
    return AdState(
      interstitialAd: interstitialAd ?? this.interstitialAd,
      rewardedAd: rewardedAd ?? this.rewardedAd,
      isInterstitialLoaded: isInterstitialLoaded ?? this.isInterstitialLoaded,
      isRewardedLoaded: isRewardedLoaded ?? this.isRewardedLoaded,
    );
  }
}
