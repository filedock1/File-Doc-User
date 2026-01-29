import 'package:filedock_user/controllers/videocontroller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

import '../adwidgets/bannerad.dart';
import '../constant/colors.dart';
import '../controllers/homescreencontroller.dart';
import '../widget/HomeTitleSubtitle.dart';
import '../widget/customtextfield.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});

  final HomeController controller = Get.put(HomeController());
  final VideoController videoController = Get.find<VideoController>(); 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: kblack,
      appBar: AppBar(
        backgroundColor: kbg1black500,
        title: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset('assets/svgicon/logo.svg', width: 33, height: 30),
              const SizedBox(width: 9),
              Image.asset('assets/images/FileDock.png', width: 136, height: 36),
            ],
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          color: kbg1black500,
          image: DecorationImage(
            image: AssetImage('assets/images/dottedimg.jpg'),
            fit: BoxFit.cover,
            opacity: 0.15,
          ),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Column(
                    children: [
                      const SizedBox(height: 10),

                      /// 🔹 Top banner
                      CustomBannerAd(bannerKey: 'home_banner1'),
                      const SizedBox(height: 40),

                      /// 🔹 Middle content
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Welcome to File',
                            style: TextStyle(
                              color: kwhite,
                              fontSize: 25,
                              fontWeight: FontWeight.w700,
                              fontFamily: 'Montserrat-Bold',
                            ),
                          ),
                          Text(
                            'Dock',
                            style: TextStyle(
                              color: kblueaccent,
                              fontSize: 25,
                              fontWeight: FontWeight.w700,
                              fontFamily: 'Montserrat-Bold',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Access File via Link',
                            style: TextStyle(
                              color: kwhite,
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              fontFamily: 'Montserrat-SemiBold',
                            ),
                          ),
                          SvgPicture.asset('assets/svgicon/link-04.svg', width: 24, height: 24),
                        ],
                      ),
                      const SizedBox(height: 10),

                      /// 🔹 TextField with loader
                      /// 🔹 TextField with loader + deep link logic
Obx(() {
  // 1️⃣ Loading
  if (controller.isLoading.value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Center(
        child: CircularProgressIndicator(color: kblueaccent),
      ),
    );
  }

  // 2️⃣ Deep link user → hide input box
  if (videoController.videoId.value.isNotEmpty) {
    return const SizedBox.shrink();
  }

  // 3️⃣ Normal user → show input box
  return FileDockTextField(
    linkController: controller.linkController,
    onTap: () {
      final input = controller.linkController.text.trim();
      if (input.isNotEmpty) {
        controller.handleLinkTap(input);
      } else {
        Get.snackbar("Error", "Please enter a valid link");
      }
    },
  );
}),

                      const SizedBox(height: 10),

                      HomeTitleSubTitle(
                        svgAssetPath: 'assets/svgicon/video-ai.svg',
                        title: 'Adaptive Video Quality',
                        subtitle:
                        'Seamlessly adjusts video resolution between 480p, 720p, and 1080p',
                      ),
                      const SizedBox(height: 10),

                      HomeTitleSubTitle(
                        svgAssetPath: 'assets/svgicon/flag-02.svg',
                        title: 'Issue Reporting',
                        subtitle:
                        'Easily report any video or playback issues directly from the app',
                      ),

                      const Spacer(),

                      /// 🔹 Fixed bottom ad
                      CustomBannerAd(bannerKey: 'home_banner2'),
                      const SizedBox(height: 10),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
