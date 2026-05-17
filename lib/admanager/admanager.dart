import 'dart:convert';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/cupertino.dart';

class AdManager {
  // Ad unit maps
  static Map<String, String> bannerAdUnitIds = {};
  static Map<String, String> nativeAdUnitIds = {}; // Changed from nativeVideoAdUnitIds to match JSON
  static Map<String, String> interstitialAdUnitIds = {};
  static Map<String, String> rewardedAdUnitIds = {}; // ⭐ NEW
  static Map<String, String> rewardedInterstitialAdUnitIds = {};

  /// 🛠️ TOGGLE THIS FOR TESTING VS PRODUCTION
  static const bool isTestMode = false;

  /// 🧪 Standard Test IDs (Google AdMob)
  static final Map<String, String> _testAdUnitIds = {
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
    "videoscreenNative3": "ca-app-pub-3940256099942544/1044960115",
    "videoscreenNative1": "ca-app-pub-3940256099942544/1044960115",
    "videoscreenNative2": "ca-app-pub-3940256099942544/1044960115",
    "videoplayerscreenNative": "ca-app-pub-3940256099942544/1044960115",

    "downloadAd": "ca-app-pub-3940256099942544/1033173712",
    "goToFullScreen": "ca-app-pub-3940256099942544/1033173712",
    "playButtonAd": "ca-app-pub-3940256099942544/1033173712",

    "rewarded_download": "ca-app-pub-3940256099942544/5224354917",
    "downlaod_button_ad": "ca-app-pub-3940256099942544/5224354917",

    "videoDownloadReward": "ca-app-pub-3940256099942544/5354046379",
    "unlockFullVideo": "ca-app-pub-3940256099942544/5354046379",
  };

  /// Fetch ad unit IDs from Remote Config (JSON)
  static Future<void> fetchRemoteConfig() async {
    final remoteConfig = FirebaseRemoteConfig.instance;

    const defaultJson = '''
{
  "banner": {
    "home_banner": "ca-app-pub-2091017524613192/2942701605",
    "videos_banner": "ca-app-pub-2091017524613192/8987418512",
    "player_banner": "ca-app-pub-2091017524613192/9106838014",
    "download_banner": "ca-app-pub-2091017524613192/6859948628",
    "more_banner": "ca-app-pub-2091017524613192/3820669009",
    "home_banner1": "ca-app-pub-2091017524613192/8812704874",
    "home_banner2": "ca-app-pub-2091017524613192/8812704874",
    "videoplayerscreen_banner1": "ca-app-pub-2091017524613192/8812704874",
    "videoplayerscreen_banner2": "ca-app-pub-2091017524613192/8812704874",
    "videoscreen_banner1": "ca-app-pub-2091017524613192/8812704874",
    "videoscreen_banner2": "ca-app-pub-2091017524613192/8812704874",
    "downloadscreen_banner1": "ca-app-pub-2091017524613192/8812704874",
    "downloadscreen_banner2": "ca-app-pub-2091017524613192/8812704874",
    "morescreen_banner1": "ca-app-pub-2091017524613192/8812704874",
    "morescreen_banner2": "ca-app-pub-2091017524613192/8812704874"
  },
  "native": {
    "home_native": "ca-app-pub-2091017524613192/1194505660",
    "videos_native": "ca-app-pub-2091017524613192/5546866954",
    "player_native": "ca-app-pub-2091017524613192/6255260652",
    "videoscreenNative1": "ca-app-pub-2091017524613192/8829958694",
    "videoscreenNative2": "ca-app-pub-2091017524613192/8829958694",
    "videoscreenNative3": "ca-app-pub-2091017524613192/8829958694",
    "videoplayerscreenNative": "ca-app-pub-2091017524613192/8829958694"
  },
  "interstitial": {
    "fullscreen_interstitial": "ca-app-pub-2091017524613192/8689852303",
    "action_interstitial": "ca-app-pub-2091017524613192/9982752673",
    "downloadAd": "ca-app-pub-2091017524613192/5158028067",
    "goToFullScreen": "ca-app-pub-2091017524613192/5158028067",
    "playButtonAd": "ca-app-pub-2091017524613192/5158028067"
  },
  "rewarded": {
    "rewarded_download": "ca-app-pub-2091017524613192/6596829981",
    "downlaod_button_ad": "ca-app-pub-2091017524613192/4962456755"
  },
  "rewarded_interstitial": {
    "unlock_video_reward": "ca-app-pub-2091017524613192/8669671000",
    "download_reward_interstitial": "ca-app-pub-2091017524613192/4409650340",
    "videoDownloadReward": "ca-app-pub-2091017524613192/6448936735",
    "unlockFullVideo": "ca-app-pub-2091017524613192/6448936735"
  }
}
''';

    await remoteConfig.setDefaults({'all_ads': defaultJson});
debugPrint("====== ADS CONFIG ======");
debugPrint("Banner Ads: $bannerAdUnitIds");
debugPrint("Native Ads: $nativeAdUnitIds");
debugPrint("Interstitial Ads: $interstitialAdUnitIds");
debugPrint("Rewarded Ads: $rewardedAdUnitIds");
debugPrint("Rewarded Interstitial Ads: $rewardedInterstitialAdUnitIds");
    try {
      await remoteConfig.fetchAndActivate();

      if (isTestMode) {
        debugPrint('🧪 TEST MODE ACTIVE: Using Test Ad Unit IDs');
        
        bannerAdUnitIds.clear();
        nativeAdUnitIds.clear();
        interstitialAdUnitIds.clear();
        rewardedAdUnitIds.clear();
        rewardedInterstitialAdUnitIds.clear();

        _testAdUnitIds.forEach((key, value) {
          if (key.contains("banner")) {
            bannerAdUnitIds[key] = value;
          } else if (key.contains("Native") || key.contains("native")) {
            nativeAdUnitIds[key] = value;
          } else if (key == "downloadAd" || key == "goToFullScreen" || key == "playButtonAd" || key.contains("interstitial")) {
            interstitialAdUnitIds[key] = value;
          } else if (key == "rewarded_download" || key == "downlaod_button_ad" || key.contains("rewarded")) {
            rewardedAdUnitIds[key] = value;
          } else if (key == "videoDownloadReward" || key == "unlockFullVideo") {
            rewardedInterstitialAdUnitIds[key] = value;
          }
        });

      } else {
        debugPrint('🧪 TEST MODE INACTIVE: Using Real Ad Unit IDs');

        final jsonString = remoteConfig.getString('all_ads');
        final Map<String, dynamic> data = json.decode(jsonString);

        bannerAdUnitIds = Map<String, String>.from(data['banner'] ?? {});
        // Fix: Use 'native' instead of 'native_video'
        nativeAdUnitIds = Map<String, String>.from(data['native'] ?? data['native_video'] ?? {});
        interstitialAdUnitIds = Map<String, String>.from(data['interstitial'] ?? {});
        rewardedAdUnitIds = Map<String, String>.from(data['rewarded'] ?? {}); // ⭐ NEW
        rewardedInterstitialAdUnitIds = Map<String, String>.from(data['rewarded_interstitial'] ?? {});
      debugPrint("====== ADS CONFIG ======");
debugPrint("Banner Ads: $bannerAdUnitIds");
debugPrint("Native Ads: $nativeAdUnitIds");
debugPrint("Interstitial Ads: $interstitialAdUnitIds");
debugPrint("Rewarded Ads: $rewardedAdUnitIds");
debugPrint("Rewarded Interstitial Ads: $rewardedInterstitialAdUnitIds");
      }
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
