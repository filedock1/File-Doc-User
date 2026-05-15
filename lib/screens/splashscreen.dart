import 'package:filedock_user/controllers/videocontroller.dart';
import 'package:filedock_user/screens/tabpage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:url_launcher/url_launcher.dart';
import '../constant/colors.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  bool _forceUpdate = false;

  Future<void> checkForUpdate() async {
    try {
      AppUpdateInfo info = await InAppUpdate.checkForUpdate();

      if (info.updateAvailability == UpdateAvailability.updateAvailable) {
        print("CHECK");
        setState(() {
          _forceUpdate = true;
        });
        if (info.immediateUpdateAllowed) {
          await InAppUpdate.performImmediateUpdate();
        } else {
          openPlayStore();
        }
      } else {
        print("REJECT");
        navigateNext();
      }
    } catch (e) {
      print("Update check failed: $e");
      navigateNext();
    }
  }

  Future<void> navigateNext() async {
    await Future.delayed(const Duration(seconds: 2));

    final vc = Get.find<VideoController>();

    if (vc.videoId.value.isNotEmpty) {
      await vc.fetchVideoDataOnly(vc.videoId.value);

      final tabPage = TabPage();
      tabPage.tabController.changeTab(1);
      Get.offAll(() => tabPage);
    } else {
      Get.offAll(() => TabPage());
    }
  }

  @override
  void initState() {
    super.initState();
    checkForUpdate();
  }
  Future<void> openPlayStore() async {
    const String packageName = "com.ignito.filedockuser"; // 🔥 CHANGE THIS
    final Uri url = Uri.parse(
        "https://play.google.com/store/apps/details?id=$packageName");

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }
  Future<void> tryImmediateUpdate() async {
    try {
      await InAppUpdate.performImmediateUpdate();
    } catch (e) {
      openPlayStore(); // fallback
    }
  }

  @override
  Widget build(BuildContext context) {

    // 🔴 If update required → Show Blank Screen
    if (_forceUpdate) {
      return WillPopScope(
        onWillPop: () async => false,
        child: Scaffold(
          backgroundColor: Colors.black,
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    height: 110,
                    width: 110,
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.system_update_alt_rounded,
                      size: 60,
                      color: Colors.blue,
                    ),
                  ),

                  const SizedBox(height: 30),

                  const Text(
                    "Update Required",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white
                    ),
                  ),

                  const SizedBox(height: 12),

                  const Text(
                    "A new version of the app is available.\nPlease update to continue using the app.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(height: 35),
                  InkWell(
                    onTap: tryImmediateUpdate,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(50),
                        border: Border.all(
                          color: kblueaccent,
                          width: 3.4,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(
                            padding:
                            const EdgeInsets.all(8),
                            child: SvgPicture.asset(
                              'assets/svgicon/download_fullscreen.svg',
                              width: 40,
                              height: 40,
                            ),
                          ),
                          SizedBox(width: 5,),
                          Text(
                            'Update App from Playstore',
                            style: TextStyle(
                              color: kwhite,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 15),

                  const Text(
                    "You cannot use this version anymore.",
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.redAccent,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    // 🟢 Normal Splash
    return Scaffold(
      backgroundColor: kbg1black500,
      body: SafeArea(
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/splash.png'),
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
    );
  }
}
