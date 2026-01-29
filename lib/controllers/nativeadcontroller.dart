import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../admanager/admanager.dart';

class NativeAdController extends GetxController {
  NativeAd? _nativeAd;
  final RxBool isLoaded = false.obs;
  final RxBool isError = false.obs;
  int _retryCount = 0;
  final int _maxRetries = 3;

  /// Load a native ad
  void loadNativeAd(String adKey) {
    final adUnitId = AdManager.nativeVideoAdUnitIds[adKey];

    if (adUnitId == null) {
      debugPrint("❌ NativeAd key '$adKey' not found!");
      isError.value = true;
      return;
    }

    // Reset state
    isLoaded.value = false;
    isError.value = false;
    _retryCount = 0;

    _nativeAd?.dispose();

    _nativeAd = NativeAd(
      adUnitId: adUnitId,
      factoryId: 'listTile',
      nativeAdOptions: NativeAdOptions(
          mediaAspectRatio: MediaAspectRatio.landscape,
          videoOptions: VideoOptions(startMuted: true, clickToExpandRequested: true),
      ),
      request: const AdRequest(),
      listener: NativeAdListener(
        onAdLoaded: (ad) {
          debugPrint("✅ Native Ad Loaded: $adKey");
          isLoaded.value = true;
          isError.value = false;
          _retryCount = 0;
        },
        onAdFailedToLoad: (ad, error) {
          debugPrint("❌ Native Ad Failed to load ($adKey): $error");
          ad.dispose();
          isLoaded.value = false;

          if (_retryCount < _maxRetries) {
            _retryCount++;
            debugPrint("🔄 Retrying Native Ad ($adKey)... Attempt: $_retryCount");
            Future.delayed(const Duration(seconds: 3), () {
              loadNativeAd(adKey);
            });
          } else {
            isError.value = true;
          }
        },
      ),
    )..load();
  }

  NativeAd? get nativeAd => _nativeAd;

  @override
  void onClose() {
    _nativeAd?.dispose();
    super.onClose();
  }
}
