import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../admanager/admanager.dart';

class BannerAdController extends GetxController {
  // Store multiple banners by key
  final Map<String, BannerAd?> _bannerAds = {};
  final Map<String, RxBool> _isLoaded = {};
  final Map<String, RxBool> _isError = {}; // 🔥 Track errors
  final Map<String, int> _retryCount = {};

  final int _maxRetries = 3;

  /// Load a banner ad by key
  void loadBannerAd(String bannerKey, {AdSize adSize = AdSize.banner}) {
    final adUnitId = AdManager.bannerAdUnitIds[bannerKey];

    if (adUnitId == null) {
      print("❌ Banner key '$bannerKey' not found!");
      return;
    }

    if (_isLoaded.containsKey(bannerKey)) {
       WidgetsBinding.instance.addPostFrameCallback((_) {
         _isLoaded[bannerKey]!.value = false;
         _isError[bannerKey]!.value = false;
       });
    } else {
      _isLoaded[bannerKey] = false.obs;
      _isError[bannerKey] = false.obs;
    }
    
    _retryCount.putIfAbsent(bannerKey, () => 0);

    _bannerAds[bannerKey]?.dispose();

    final banner = BannerAd(
      adUnitId: "ca-app-pub-2091017524613192/7904491152",
      size: adSize, 
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          _isLoaded[bannerKey]?.value = true;
          _isError[bannerKey]?.value = false; // Success
          _retryCount[bannerKey] = 0;
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          _isLoaded[bannerKey]?.value = false;

          final retry = (_retryCount[bannerKey] ?? 0) + 1;
          if (retry <= _maxRetries) {
            _retryCount[bannerKey] = retry;
            Future.delayed(const Duration(seconds: 3), () {
              loadBannerAd(bannerKey, adSize: adSize);
            });
          } else {
             // Retries exhausted, hide UI
             _isError[bannerKey]?.value = true;
          }
        },
      ),
    );

    _bannerAds[bannerKey] = banner;
    banner.load();
  }

  /// Get banner instance for AdWidget
  BannerAd? getBanner(String bannerKey) => _bannerAds[bannerKey];

  /// Reactive loaded state
  RxBool isBannerLoaded(String bannerKey) {
    return _isLoaded.putIfAbsent(bannerKey, () => false.obs);
  }

  /// Reactive error state
  RxBool isBannerError(String bannerKey) {
    return _isError.putIfAbsent(bannerKey, () => false.obs);
  }

  @override
  void onClose() {
    for (final ad in _bannerAds.values) {
      ad?.dispose();
    }
    _bannerAds.clear();
    super.onClose();
  }
}
