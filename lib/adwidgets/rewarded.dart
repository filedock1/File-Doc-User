import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class RewardedAdManager {
  RewardedAd? _rewardedAd;

  void showAd({
    required String adUnitId,
    required Function(bool earned) onComplete,
  }) {
    debugPrint("⏳ Loading Standard Rewarded Ad: $adUnitId");

    RewardedAd.load(
      adUnitId: adUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (RewardedAd ad) {
          debugPrint("✅ Rewarded Ad Loaded");

          _rewardedAd = ad;

          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              debugPrint("❌ Ad Dismissed");
              ad.dispose();
              onComplete(false);
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              debugPrint("❌ Ad Failed to Show: $error");
              ad.dispose();
              onComplete(false);
            },
          );

          ad.show(
            onUserEarnedReward: (ad, reward) {
              debugPrint("✅ User earned reward: ${reward.amount}");
              onComplete(true);
            },
          );
        },
        onAdFailedToLoad: (LoadAdError error) {
          debugPrint("❌ Rewarded Ad Failed to Load: $error");
          onComplete(false);
        },
      ),
    );
  }
}
