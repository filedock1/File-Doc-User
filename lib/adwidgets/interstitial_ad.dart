import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter/foundation.dart';

class InterstitialAdManager {
  InterstitialAd? _interstitialAd;
  bool _isLoading = false;

  /// Load and show interstitial ad, then call [onComplete] after ad dismissed or failed
  void showAd({required String adUnitId, required VoidCallback onComplete}) {
    if (_isLoading) return; // avoid multiple requests
    _isLoading = true;

    InterstitialAd.load(
      adUnitId: adUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _isLoading = false;
          _interstitialAd = ad;

          _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              onComplete(); // continue after ad closed
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              ad.dispose();
              onComplete(); // fallback
            },
          );

          _interstitialAd!.show();
        },
        onAdFailedToLoad: (error) {
          _isLoading = false;
          debugPrint("❌ Interstitial failed: $error");
          onComplete(); // fallback if ad not loaded
        },
      ),
    );
  }

  void dispose() {
    _interstitialAd?.dispose();
  }
}
