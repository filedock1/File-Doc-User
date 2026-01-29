import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter/foundation.dart';

class RewardedInterstitialAdManager {
  RewardedAd? _rewardedAd; // 🔥 Changed to Standard RewardedAd
  bool _isLoading = false;

  /// Load and show rewarded ad (Standard)
  /// [onComplete] returns true if reward was earned, false otherwise
  void showAd({required String adUnitId, required Function(bool) onComplete}) {
    if (_isLoading) return;
    _isLoading = true;

    debugPrint("⏳ Loading Standard Rewarded Ad: $adUnitId");

    RewardedAd.load(
      adUnitId: adUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          debugPrint("✅ Rewarded Ad Loaded");
          _isLoading = false;
          _rewardedAd = ad;
          bool isCompleted = false;
          bool rewardEarned = false; // 🔥 Track reward

          _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              debugPrint("❌ Ad Dismissed");
              ad.dispose();
              if (!isCompleted) {
                isCompleted = true;
                // Pass reward status
                Future.delayed(const Duration(milliseconds: 200), () => onComplete(rewardEarned)); 
              }
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              debugPrint("❌ Ad Failed to Show: $error");
              ad.dispose();
              if (!isCompleted) {
                isCompleted = true;
                // Ad failed to show, assume false or maybe fallback? 
                // Let's return false to be safe, or true to be lenient. 
                // Strict: false.
                Future.delayed(const Duration(milliseconds: 200), () => onComplete(false)); 
              }
            },
          );

          _rewardedAd!.show(
            onUserEarnedReward: (ad, reward) {
              debugPrint("✅ User earned reward: ${reward.amount}");
              rewardEarned = true; // 🔥 Set flag
            },
          );
        },
        onAdFailedToLoad: (error) {
          _isLoading = false;
          debugPrint("❌ Rewarded Ad failed to load: $error");
          // If ad failed to load, usually allow the user to proceed (lenient)
          onComplete(true); 
        },
      ),
    );
  }

  void dispose() {
    _rewardedAd?.dispose();
  }
}
