import 'dart:async';

import 'package:filedock_user/model/videomodel.dart';
import 'package:filedock_user/screens/videoplayerscreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

import '../admanager/admanager.dart';
import '../adwidgets/bannerad.dart';
import '../adwidgets/native_ad.dart';
import '../adwidgets/rewardedad.dart';
import '../constant/colors.dart';
import '../controllers/videocontroller.dart';
import '../model/playercount.dart';
import '../widget/bouncing_button.dart';

class VideoScreen extends StatefulWidget {
  const VideoScreen({super.key});

  @override
  State<VideoScreen> createState() => _VideoScreenState();
}

class _VideoScreenState extends State<VideoScreen> {
  final VideoController videoController = Get.put(VideoController());

  bool _isLoading = false;
  bool _isButtonVisible = false;
  int _adsProcessedCount = 0;

  // ⏳ COUNTDOWN STATE
  bool _isCountdown = false;
  int _countdown = 5;
  Timer? _countdownTimer;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted && !_isButtonVisible) {
        setState(() => _isButtonVisible = true);
      }
    });
  }

  void _onAdProcessed() {
    _adsProcessedCount++;
    if (_adsProcessedCount >= 4 && mounted && !_isButtonVisible) {
      setState(() => _isButtonVisible = true);
    }
  }

  // ⏳ Start Countdown Before Opening Player
  void _startCountdown(VoidCallback openPlayer) {
    setState(() {
      _isCountdown = true;
      _countdown = 5;
    });

    _countdownTimer?.cancel();
    _countdownTimer =
        Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      if (_countdown == 1) {
        timer.cancel();
        setState(() => _isCountdown = false);
        openPlayer(); // ▶️ Continue Player + Ad Flow
      } else {
        setState(() => _countdown--);
      }
    });
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kblack,
      appBar: AppBar(
        backgroundColor: kbg1black500,
        toolbarHeight: 2,
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          color: kbg1black500,
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(1),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: NativeVideoAdCard(
                    adKey: 'videoscreenNative2',
                    onAdLoaded: _onAdProcessed,
                  ),
                ),
                const SizedBox(height: 20),
                if (!_isButtonVisible)
                  Container(
                    height: 44,
                    width: 179,
                    alignment: Alignment.center,
                    child: const Text(
                      "Please wait...",
                      style:
                          TextStyle(color: Colors.white54, fontSize: 14),
                    ),
                  )
                else
                  BouncingButton(
                    onTap: () {
                      if (_isLoading || _isCountdown) return;

                      if (videoController.videoUrl.value.isEmpty ||
                          videoController.videoId.value.isEmpty) {
                        Get.snackbar(
                            "Error", "No video available to play");
                        return;
                      }

                      setState(() => _isLoading = true);

                      PlayCounter.increment();

                      final VideoModel model = VideoModel(
                        id: videoController.videoId.value,
                        url: videoController.videoUrl.value,
                        localPath: null,
                        title: videoController.videoTitle.value,
                        views: videoController.videoViews.value,
                        clickCount:
                            videoController.videoClickCount.value,
                        size: videoController.videoSize.value,
                        date: videoController.videoDate.value,
                      );

                      void openPlayer() {
                        setState(() => _isLoading = false);
                        Get.to(() =>
                            VideoPlayerScreen(videoModel: model));
                      }

                      _startCountdown(() {
                        if ( PlayCounter.playCount % 2 == 1) {
                          RewardedInterstitialAdManager().showAd(
                            adUnitId:"ca-app-pub-2091017524613192/4962456755",
                            onComplete: (earned) {
                              if (earned) {
                                openPlayer();
                              } else {
                                setState(() => _isLoading = false);
                              }
                            },
                          );
                        } else {
                          openPlayer();
                        }
                      });
                    },
                    child: Container(
                      height: 49,
                      width: 189,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(50),
                        border: Border.all(
                          color: kblueaccent,
                          width: 3.4,
                        ),
                      ),
                      child: _isLoading
                          ? const Center(
                              child: SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2.5,
                                ),
                              ),
                            )
                          : _isCountdown
                              ? Center(
                                  child: Text(
                                    "Starting in $_countdown...",
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                )
                              : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Padding(
                                      padding:
                                          const EdgeInsets.all(8),
                                      child: SvgPicture.asset(
                                        'assets/svgicon/Polygon 2.svg',
                                        width: 40,
                                        height: 40,
                                      ),
                                    ),
                                    Text(
                                      'Play Video',
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

                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.only(left: 20.0,right: 20,top: 20),
                  child: NativeVideoAdCard(
                    adKey: 'videoscreenNative1',
                    onAdLoaded: _onAdProcessed,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
