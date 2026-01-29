import 'package:filedock_user/screens/downloadscreen.dart';
import 'package:filedock_user/screens/homescreen.dart';
import 'package:filedock_user/screens/morescreen.dart';
import 'package:filedock_user/screens/videoscreen.dart';
import 'package:filedock_user/screens/videoplayerscreen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/tabcontroller.dart';
import '../widget/custombottomnav.dart';

class TabPage extends StatelessWidget {
  TabPage({super.key});

  final TabControllerX tabController = Get.put(TabControllerX());

  final List<String> _icons = [
    'assets/svgicon/home-03 (1).svg',
    'assets/svgicon/play-circle.svg',
    'assets/svgicon/download-square-01.svg',
    'assets/svgicon/more-horizontal-square-02.svg',
  ];

  final List<Widget> _pages = [
    HomeScreen(),
    VideoScreen(),
    DownloadScreen(),
    MoreScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Obx(() => Scaffold(
      backgroundColor: Colors.black,
      body: _pages[tabController.selectedIndex.value],
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(bottom: 20), // floating effect
        child: CustomBottomNavBar(
          icons: _icons,
          selectedIndex: tabController.selectedIndex.value,
          onTap: (index) => tabController.changeTab(index),
        ),
      ),
    ));
  }
}
