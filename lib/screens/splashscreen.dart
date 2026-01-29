

/*import 'package:filedock_user/screens/tabpage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../constant/colors.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Future.delayed(Duration(seconds: 3),() {
      Get.off(()=> TabPage());
    },);
    return Scaffold(
      backgroundColor: kbg1black500, // 👈 This makes the area above SafeArea black
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
*/

import 'package:filedock_user/controllers/videocontroller.dart';
import 'package:filedock_user/screens/tabpage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../constant/colors.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(seconds: 2), () async {
      final vc = Get.find<VideoController>();

      if (vc.videoId.value.isNotEmpty) {
        // 🔥 Fetch Data Only (No Auto Play) -> Go to TabPage -> Tab 1
        await vc.fetchVideoDataOnly(vc.videoId.value);
        
        final tabPage = TabPage();
        tabPage.tabController.changeTab(1); // Set to Video Screen
        Get.offAll(() => tabPage);
      } else {
        Get.offAll(() => TabPage()); // ✅ BottomNavigation yahin milega
      }
    });
  }

  @override
  Widget build(BuildContext context) {
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
