import 'dart:convert';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/cupertino.dart';

class AdManager {
  // Ad unit maps
  static Map<String, String> bannerAdUnitIds = {};
  static Map<String, String> nativeVideoAdUnitIds = {};
  static Map<String, String> interstitialAdUnitIds = {};
  static Map<String, String> rewardedInterstitialAdUnitIds = {}; // ⭐ NEW

  /// 🛠️ TOGGLE THIS FOR TESTING VS PRODUCTION
  static const bool isTestMode = true;

  /// 🧪 Standard Test IDs (Google AdMob)
  static final Map<String, String> _testAdUnitIds = {
    // Banner
    "home_banner1": "ca-app-pub-3940256099942544/6300978111",
    "home_banner2": "ca-app-pub-3940256099942544/6300978111",
    "videoplayerscreen_banner1": "ca-app-pub-3940256099942544/6300978111",
    "videoplayerscreen_banner2": "ca-app-pub-3940256099942544/6300978111",
    "videoscreen_banner1": "ca-app-pub-3940256099942544/6300978111",
    "videoscreen_banner2": "ca-app-pub-3940256099942544/6300978111",
    "downloadscreen_banner1": "ca-app-pub-3940256099942544/6300978111",
    "downloadscreen_banner2": "ca-app-pub-3940256099942544/6300978111",
    "morescreen_banner1": "ca-app-pub-3940256099942544/6300978111",
    "morescreen_banner2": "ca-app-pub-3940256099942544/6300978111",

    // Native Video (Using Native Advanced Video Test ID)
    "videoscreenNative1": "ca-app-pub-3940256099942544/1044960115", // ✅ Native Advanced Image
    "videoscreenNative2": "ca-app-pub-3940256099942544/1044960115", // ✅ Using Image Advanced for stability
    "videoplayerscreenNative": "ca-app-pub-3940256099942544/1044960115", // ✅ Image Advanced for now

    // Interstitial
    "downloadAd": "ca-app-pub-3940256099942544/1033173712",
    "goToFullScreen": "ca-app-pub-3940256099942544/1033173712",
    "playButtonAd": "ca-app-pub-3940256099942544/1033173712",

    // Rewarded Interstitial (Actually using Standard Rewarded in code)
    "videoDownloadReward": "ca-app-pub-3940256099942544/5224354917", // Was ...5354046379
    "unlockFullVideo": "ca-app-pub-3940256099942544/5224354917",     // Was ...5354046379
  };

  /// Fetch ad unit IDs from Remote Config (JSON)
  static Future<void> fetchRemoteConfig() async {
    final remoteConfig = FirebaseRemoteConfig.instance;

    const defaultJson = '''
{
  "banner": {
    "home_banner1": "ca-app-pub-6783189810116421/6250931152",
    "home_banner2": "ca-app-pub-6783189810116421/6250931152",
    "videoplayerscreen_banner1": "ca-app-pub-6783189810116421/6250931152",
    "videoplayerscreen_banner2": "ca-app-pub-6783189810116421/6250931152",
    "videoscreen_banner1": "ca-app-pub-6783189810116421/6250931152",
    "videoscreen_banner2": "ca-app-pub-6783189810116421/6250931152",
    "downloadscreen_banner1": "ca-app-pub-6783189810116421/6250931152",
    "downloadscreen_banner2": "ca-app-pub-6783189810116421/6250931152",
    "morescreen_banner1": "ca-app-pub-6783189810116421/6250931152",
    "morescreen_banner2": "ca-app-pub-6783189810116421/6250931152"
  },

  "native_video": {
    "videoscreenNative1": "ca-app-pub-6783189810116421/9600552567",
    "videoscreenNative2": "ca-app-pub-6783189810116421/9600552567",
    "videoplayerscreenNative": "ca-app-pub-6783189810116421/9600552567"
  },

  "interstitial": {
    "downloadAd": "ca-app-pub-6783189810116421/7528922999",
    "goToFullScreen": "ca-app-pub-6783189810116421/7528922999",
    "playButtonAd": "ca-app-pub-6783189810116421/7528922999"
  },

  "rewarded_interstitial": {
    "videoDownloadReward": "ca-app-pub-6783189810116421/1304998253",
    "unlockFullVideo": "ca-app-pub-6783189810116421/1304998253"
  }
}
''';

    await remoteConfig.setDefaults({'all_ads': defaultJson});

    try {
      await remoteConfig.fetchAndActivate();

      if (isTestMode) {
        debugPrint('🧪 TEST MODE ACTIVE: Using Test Ad Unit IDs');
        
        // Populate all maps with test IDs
        bannerAdUnitIds.clear();
        nativeVideoAdUnitIds.clear();
        interstitialAdUnitIds.clear();
        rewardedInterstitialAdUnitIds.clear();

        _testAdUnitIds.forEach((key, value) {
          // Naive assignment based on key naming convention 
          // (robust enough since we know the keys we are using)
          if (key.contains("banner")) {
            bannerAdUnitIds[key] = value;
          } else if (key.contains("Native")) {
            nativeVideoAdUnitIds[key] = value;
          } else if (key == "downloadAd" || key == "goToFullScreen" || key == "playButtonAd") {
            interstitialAdUnitIds[key] = value;
          } else if (key == "videoDownloadReward" || key == "unlockFullVideo") {
            rewardedInterstitialAdUnitIds[key] = value;
          }
        });

      } else {
        final jsonString = remoteConfig.getString('all_ads');
        final Map<String, dynamic> data = json.decode(jsonString);

        bannerAdUnitIds =
            Map<String, String>.from(data['banner'] ?? {});
        nativeVideoAdUnitIds =
            Map<String, String>.from(data['native_video'] ?? {});
        interstitialAdUnitIds =
            Map<String, String>.from(data['interstitial'] ?? {});
        rewardedInterstitialAdUnitIds =
            Map<String, String>.from(data['rewarded_interstitial'] ?? {}); // ⭐
      }

      /*
      debugPrint('✅ Banner IDs: $bannerAdUnitIds');
      debugPrint('✅ Native Video IDs: $nativeVideoAdUnitIds');
      debugPrint('✅ Interstitial IDs: $interstitialAdUnitIds');
      debugPrint('✅ Rewarded Interstitial IDs: $rewardedInterstitialAdUnitIds');
      */
    } catch (e) {
      debugPrint('⚠️ Remote Config fetch failed: $e');
    }
  }
  /// ⭐ Show Interstitial Ad then call callback
  static void showInterstitialAd({required VoidCallback onAdClosed, required String adUnitId}) {
    if (adUnitId.isEmpty) {
      debugPrint("⚠️ Ad Unit ID is empty. Skipping ad.");
      onAdClosed();
      return;
    }

    debugPrint("⏳ Loading Interstitial Ad: $adUnitId");

    InterstitialAd.load(
      adUnitId: adUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (InterstitialAd ad) {
          debugPrint("✅ Interstitial Ad Loaded");
          
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              debugPrint("❌ Ad Dismissed");
              ad.dispose();
              onAdClosed(); // 🔥 Continue flow
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              debugPrint("❌ Ad Failed to Show: $error");
              ad.dispose();
              onAdClosed(); // 🔥 Continue flow
            },
          );

          ad.show();
        },
        onAdFailedToLoad: (LoadAdError error) {
          debugPrint("❌ Interstitial Ad Failed to Load: $error");
          onAdClosed(); // 🔥 Fallback: Continue flow
        },
      ),
    );
  }
}
