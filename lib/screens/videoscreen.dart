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

    // Fallback: show button after 8 sec if ads hang
    Future.delayed(const Duration(seconds: 8), () {
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
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset('assets/svgicon/logo.svg', width: 33),
            const SizedBox(width: 9),
            Image.asset('assets/images/FileDock.png', width: 136),
          ],
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          color: kbg1black500,
          image: const DecorationImage(
            image: AssetImage('assets/images/dottedimg.jpg'),
            fit: BoxFit.cover,
            opacity: 0.15,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  /// 🔝 TOP BANNER
                  CustomBannerAd(
                    bannerKey: 'videoscreen_banner1',
                    onAdLoaded: _onAdProcessed,
                  ),
                  const SizedBox(height: 10),

                  /// 🧩 NATIVE AD
                  NativeVideoAdCard(
                    adKey: 'videoscreenNative1',
                    onAdLoaded: _onAdProcessed,
                  ),
                  const SizedBox(height: 20),

                  /// ▶️ PLAY BUTTON / COUNTDOWN
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

                        // ⏳ FIRST countdown → THEN ad → THEN player
                        _startCountdown(() {
                          if (PlayCounter.playCount == 1 ||
                              PlayCounter.playCount % 5 == 0) {
                            RewardedInterstitialAdManager().showAd(
                              adUnitId:
                                  AdManager.rewardedInterstitialAdUnitIds[
                                      'unlockFullVideo']!,
                              onComplete: (earned) {
                                if (earned) {
                                  openPlayer();
                                } else {
                                  setState(() => _isLoading = false);
                                  Get.snackbar("Locked",
                                      "Watch the ad to play the video.");
                                }
                              },
                            );
                          } else {
                            openPlayer();
                          }
                        });
                      },
                      child: Container(
                        height: 44,
                        width: 179,
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

                  /// 🧩 SECOND NATIVE AD
                  NativeVideoAdCard(
                    adKey: 'videoscreenNative2',
                    onAdLoaded: _onAdProcessed,
                  ),
                  const SizedBox(height: 10),

                  /// 🔻 BOTTOM BANNER
                  CustomBannerAd(
                    bannerKey: 'videoscreen_banner2',
                    onAdLoaded: _onAdProcessed,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
