import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../admanager/admanager.dart';
import 'package:flutter/foundation.dart'; // kReleaseMode

class NativeAdController extends GetxController {
  NativeAd? _nativeAd;
  final RxBool isLoaded = false.obs;
  final RxBool isError = false.obs;
  final RxString errorMessage = "".obs;
  int _retryCount = 0;
  final int _maxRetries = 3;

  void loadNativeAd(String adKey) {
    final adUnitId = AdManager.nativeAdUnitIds[adKey];
    debugPrint("Loading native ad for key: $adKey");
    debugPrint("Ad unit found: $adUnitId");

    if (adUnitId == null) {
      isError.value = true;
      errorMessage.value = "Ad ID not found";
      return;
    }

    _nativeAd?.dispose();

    // 🔥 Prevent state change during build
    Future.microtask(() {
      isLoaded.value = false;
      isError.value = false;
      errorMessage.value = "";
    });

    _nativeAd = NativeAd(
      adUnitId: adUnitId,
      factoryId: 'listTile',
      nativeAdOptions: NativeAdOptions(
        mediaAspectRatio: MediaAspectRatio.any,
        videoOptions: VideoOptions(
          startMuted: true,
          clickToExpandRequested: true,
        ),
      ),
      request: const AdRequest(),
      listener: NativeAdListener(
        onAdLoaded: (ad) {
          debugPrint("✅ Native VIDEO loaded: $adKey");
          isLoaded.value = true;
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          isError.value = true;
          errorMessage.value = error.message;
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
