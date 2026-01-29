import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:filedock_user/screens/videoplayerscreen.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import '../model/videomodel.dart';
import '../admanager/admanager.dart';
import '../adwidgets/rewardedad.dart';

class VideoController extends GetxController {
  /// ⭐ Required for deep link matching
  var videos = <VideoModel>[].obs;

  var videoId = ''.obs;
  var videoUrl = ''.obs;
  var videoTitle = ''.obs;
  var videoSize = ''.obs;
  var videoDate = DateTime.now().obs;
  var videoViews = 0.obs;
  var videoClickCount = 0.obs;

  /// ✅ Deep link handler (NO navigation)
void playFromDeepLink(String id) {
  videoId.value = id;

  debugPrint("▶️ Deep link video id set: $id");
}


  /// ⭐ Deep Link — find video in local list
  VideoModel? getVideoById(String id) {
    try {
      return videos.firstWhere((video) => video.id == id);
    } catch (e) {
      print("VIDEO NOT FOUND LOCALLY FOR ID = $id");
      return null;
    }
  }

  /// ⭐ Deep Link — fetch video from Firebase then open
  Future<void> openVideoById(String id) async {
    print("🔍 Fetching deep link video from Firebase: $id"); // 🔥 Log attempt

    final snap = await FirebaseFirestore.instance
        .collection("videos")
        .doc(id)
        .get();

    if (!snap.exists) {
      print("❌ VIDEO NOT FOUND IN FIREBASE for ID: $id");
      return;
    }

    final data = snap.data()!;
    debugPrint("✅ Full Video Data Keys: ${data.keys}"); // 🔥 Check key names
    debugPrint("✅ Video Found: ${data['title']} | URL: ${data['url']}");

    final video = VideoModel.fromJson(data);
    
    // Check if URL is valid
    if (video.url.isEmpty) {
       print("❌ Video URL is EMPTY!");
       return;
    }

    // 🔥 Update Controller Observables so UI (like Views) is correct
    setVideoData(
      id: video.id,
      url: video.url,
      title: video.title,
      size: video.size,
      date: video.date,
      views: video.views,
      clickCount: video.clickCount,
    );

    // 🔥 Show Ad Before Playing
    final adId = AdManager.rewardedInterstitialAdUnitIds['unlockFullVideo'];
    
    if (adId != null && adId.isNotEmpty) {
      RewardedInterstitialAdManager().showAd(
        adUnitId: adId,
        onComplete: (bool earned) {
          if (earned) {
            print("✅ Ad Complete & Reward Earned. Navigating to Player for $id");
            Get.to(() => VideoPlayerScreen(videoModel: video));
          } else {
             print("❌ Ad Skipped or Not Completed");
             Get.snackbar("Watch Full Ad", "You must watch the entire ad to unlock the video.");
          }
        },
      );
    } else {
       // Fallback if no ad ID
       print("⚠️ No Ad ID found. Navigating directly.");
       Get.to(() => VideoPlayerScreen(videoModel: video));
    }
  }

  /// ⭐ Fetch Only (No Auto Play)
  Future<bool> fetchVideoDataOnly(String id) async {
    print("🔍 Fetching deep link video (No Play): $id");

    try {
      final snap = await FirebaseFirestore.instance.collection("videos").doc(id).get();

      if (!snap.exists) {
        print("❌ VIDEO NOT FOUND IN FIREBASE for ID: $id");
        return false;
      }

      final data = snap.data()!;
      final video = VideoModel.fromJson(data);

      if (video.url.isEmpty) return false;

      // 🔥 Update Controller Observables
      setVideoData(
        id: video.id,
        url: video.url,
        title: video.title,
        size: video.size,
        date: video.date,
        views: video.views,
        clickCount: video.clickCount,
      );
      
      return true;
    } catch (e) {
      print("❌ Error fetching video: $e");
      return false;
    }
  }


  /// Store current video data
  void setVideoData({
    required String id,
    required String url,
    required String title,
    required String size,
    required DateTime date,
    required int views,
    int clickCount = 0,
  }) {
    videoId.value = id;
    videoUrl.value = url;
    videoTitle.value = title;
    videoSize.value = size;
    videoDate.value = date;
    videoViews.value = views;
    videoClickCount.value = clickCount;
  }

  /// Firestore view + click logic
  Future<void> countViewAndEarning(VideoModel video) async {
    if (!video.url.startsWith("http")) return;

    try {
      final deviceInfo = DeviceInfoPlugin();
      String deviceId = "unknown_device";

      if (GetPlatform.isAndroid) {
        deviceId = (await deviceInfo.androidInfo).id;
      } else if (GetPlatform.isIOS) {
        deviceId = (await deviceInfo.iosInfo).identifierForVendor ?? "unknown_ios";
      }

      final db = FirebaseFirestore.instance;
      final videoRef = db.collection("videos").doc(video.id);
      final videoSnap = await videoRef.get();

      if (!videoSnap.exists) return;

      final uploaderId = videoSnap['userId'];

      final clickKey = "${deviceId}_$uploaderId";
      final clickRef = db.collection("device_clicks").doc(clickKey);
      final clickSnap = await clickRef.get();

      int clicksToday = clickSnap.exists ? (clickSnap["clicks"] ?? 0) : 0;
      Timestamp? lastResetTs = clickSnap.exists ? clickSnap["last_reset"] : null;

      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      bool reset = false;

      if (lastResetTs == null) {
        reset = true;
      } else {
        final lastDate = lastResetTs.toDate();
        final lastDay = DateTime(lastDate.year, lastDate.month, lastDate.day);

        if (lastDay.isBefore(today)) reset = true;
      }

      if (reset) clicksToday = 0;

      final batch = db.batch();

      final uniqueKey = "${deviceId}_${video.id}";
      final uniqueRef = db.collection("uniqueViews").doc(uniqueKey);
      final uniqueSnap = await uniqueRef.get();

      if (!uniqueSnap.exists) {
        batch.set(uniqueRef, {
          "deviceId": deviceId,
          "videoId": video.id,
          "createdAt": FieldValue.serverTimestamp(),
        });

        batch.set(
          videoRef,
          {"uniqueViews": FieldValue.increment(1)},
          SetOptions(merge: true),
        );
      }

      batch.set(
        videoRef,
        {"views": FieldValue.increment(1)},
        SetOptions(merge: true),
      );

      if (clicksToday < 8) {
        batch.set(
          videoRef,
          {"clickCount": FieldValue.increment(1)},
          SetOptions(merge: true),
        );
      }

      batch.set(
        clickRef,
        {
          "clicks": clicksToday + 1,
          "last_reset": FieldValue.serverTimestamp(),
          "deviceId": deviceId,
          "uploaderId": uploaderId,
        },
        SetOptions(merge: true),
      );

      await batch.commit();

      videoViews.value += 1;
      if (clicksToday < 8) videoClickCount.value += 1;

    } catch (e, st) {
      print("❌ ERROR: $e\n$st");
    }
  }
}
