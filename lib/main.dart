import 'package:filedock_user/admanager/admanager.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:filedock_user/controllers/videocontroller.dart';
import 'package:filedock_user/firebase_options.dart';
import 'package:filedock_user/screens/splashscreen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:app_links/app_links.dart';
import 'package:filedock_user/controllers/tabcontroller.dart'; // ✅ Import access to TabControllerX


Future<void> initDeepLinks() async {
  final appLinks = AppLinks();

  // Handle when app was closed
  final Uri? initialUri = await appLinks.getInitialLink();
  if (initialUri != null) {
    handleDeepLink(initialUri);
  }

  // Handle when app is running
  appLinks.uriLinkStream.listen((Uri uri) {
    handleDeepLink(uri);
  });
}

void handleDeepLink(Uri uri) {
  print("🔥 DEEP LINK: $uri");

  String? videoId;

  // 1. Custom Scheme: myapp://details?id=VIDEO_ID
  if (uri.scheme == "myapp" && uri.host == "details") {
    videoId = uri.queryParameters["id"];
  }

  // 2. App Link / Deep Link: https://filedock.in/VIDEO_ID
  if ((uri.scheme == "https" || uri.scheme == "http") &&
      uri.host == "filedock.in") {
    if (uri.pathSegments.isNotEmpty) {
      videoId = uri.pathSegments.last;
    }
  }

  if (videoId != null && videoId.isNotEmpty) {
    print("🔥 DEEP LINK DETECTED: $videoId");
    final vc = Get.find<VideoController>();

    // 🔥 store id (for splash)
    vc.videoId.value = videoId;

    // 🔥 Fetch Data Only (No Auto Play)
    vc.fetchVideoDataOnly(videoId).then((success) {
      if (success) {
        // If app is already running (TabController exists), switch to Video Tab
        try {
          // Import TabControllerX to find it
          final tabController = Get.find<TabControllerX>(); 
          tabController.changeTab(1); // 1 = Video Screen
        } catch (e) {
             print("⚠️ TabController not found yet (App might be starting): $e");
        }
      }
    });
  }
}


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  await FlutterDownloader.initialize(debug: true, ignoreSsl: true);
  
   MobileAds.instance.initialize();

  await AdManager.fetchRemoteConfig();

  Get.put(VideoController());
  MobileAds.instance.updateRequestConfiguration(
    RequestConfiguration(
      testDeviceIds: ["B13AF4D0C186E428120F046F167286B1"],
    ),
  );
  await initDeepLinks();

  runApp(const MyApp());
}



class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(390, 544),
      builder: (_, __) {
        return GetMaterialApp(
          debugShowCheckedModeBanner: false,
          home: SplashScreen(),
        );
      },
    );
  }
}
