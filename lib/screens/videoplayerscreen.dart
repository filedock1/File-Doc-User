import 'dart:async';
import 'dart:io';

import 'package:filedock_user/model/videomodel.dart';
import 'package:filedock_user/controllers/downloadcontroller.dart'; // ✅ import controller
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:video_player/video_player.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:flutter/services.dart'; // ✅ For explicit orientation control

import '../admanager/admanager.dart';
import '../adwidgets/bannerad.dart';
import '../adwidgets/native_ad.dart';
import '../adwidgets/rewardedad.dart';
import '../constant/colors.dart';
import '../controllers/videocontroller.dart';

////////////////////////////////////////////////////////////
/// VIDEO PLAYER SCREEN
////////////////////////////////////////////////////////////

class VideoPlayerScreen extends StatefulWidget {
  final VideoModel videoModel;

  const VideoPlayerScreen({
    super.key,
    required this.videoModel,
  });

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  final videoController = Get.find<VideoController>();
  final downloadController = Get.put(DownloadController(), permanent: true); // ✅ Persistent Controller

  // bool _isDownloading = false; // ❌ Removed
  // double _downloadProgress = 0.0; // ❌ Removed
  bool _isAdLoading = false; // ⏳ Loading state for download button
  bool _isDownloaded = false;


  @override
  void initState() {
    super.initState();
    _checkIfDownloaded(); // ✅ Check on init
  }

  Future<void> _checkIfDownloaded() async {
    try {
      final dir = Platform.isAndroid 
          ? await getExternalStorageDirectory() 
          : await getApplicationDocumentsDirectory();
          
      if (dir == null) return;
      String name = widget.videoModel.title.replaceAll(" ", "_");
      if (!name.endsWith(".mp4")) name = "$name.mp4";
      final videoPath = "${dir.path}/$name";
      if (await File(videoPath).exists()) {
        if (mounted) setState(() => _isDownloaded = true);
      }
    } catch (e) {
      debugPrint("Error checking download status: $e");
    }
  }

  // ---------------- VIDEO AD ----------------

void _showVideoAdBeforePlay() {
  final adId =
      AdManager.rewardedInterstitialAdUnitIds['unlockFullVideo'];

  if (adId == null || adId.isEmpty) {
    return;
  }

  RewardedInterstitialAdManager().showAd(
    adUnitId: adId,
    onComplete: (bool earned) {
      debugPrint("✅ Video unlock ad completed. Earned: $earned");
      if (earned) {
// 🔥 ALLOW VIDEO
      } else {
         Get.snackbar("Watch Full Ad", "You must watch the entire ad to unlock video.");
      }
    },
  );
}



  // ---------------- DOWNLOAD ----------------

  // ---------------- DOWNLOAD ----------------
  
  // ❌ _startDownload REMOVED (Moved to Controller)

  Future<void> _downloadWithAd(VideoModel video) async {
    if (_isAdLoading) return; // 🔒 Prevent double clicks

    setState(() => _isAdLoading = true); // ⏳ Start loading

    final adId =
        AdManager.rewardedInterstitialAdUnitIds['videoDownloadReward'];

    if (adId == null || adId.isEmpty) {
      downloadController.startDownload(video);
      if (mounted) setState(() => _isAdLoading = false);
      return;
    }

    // 🔥 DEBUG: Log Ad ID
    debugPrint("🎬 Ad Request ID: $adId");

    RewardedInterstitialAdManager().showAd(
      adUnitId: adId,
      onComplete: (bool earned) {
        if (mounted) setState(() => _isAdLoading = false); // 🔓 Stop loading
        debugPrint("🎬 Ad Completion Callback: earned=$earned");
        
        // 🔥 DEBUG: ALLOW DOWNLOAD ANYWAY (To fix user issue)
        if (earned) {
          debugPrint("✅ Reward Earned. Starting Download...");
          downloadController.startDownload(video); 
        } else {
          debugPrint("⚠️ Ad Skipped. Download Allowed for Debug.");
          Get.snackbar("Debug", "Ad Skipped but Download Started");
          downloadController.startDownload(video); // 🔥 FORCE START
        }
      },
    );
  }






  String _dateText(DateTime dt) {
    final d = DateTime.now().difference(dt).inDays;
    if (d == 0) return "Today";
    if (d == 1) return "1 day ago";
    return "$d days ago";
  }

  bool _isFullScreen = false; // 📺 Fullscreen state managed by parent

  void _toggleFullScreen() {
    setState(() {
      _isFullScreen = !_isFullScreen;
    });

    if (_isFullScreen) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    } else {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
      ]);
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    }
  }

  @override
  void dispose() {
    // Ensure we reset to portrait if leaving screen while in fullscreen
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]); 
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 🔙 Handle Back Button to exit Fullscreen first
    return PopScope(
      canPop: !_isFullScreen,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (_isFullScreen) {
          _toggleFullScreen();
        }
      },
      child: _isFullScreen ? _buildFullScreenPlayer() : _buildNormalScreen(),
    );
  }

  Widget _buildFullScreenPlayer() {
     final video = widget.videoModel;
     final String playPath = resolveVideoPath(video);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: CustomVideoPlayer(
          videoModel: video,
          videoPath: playPath,
          isFullScreen: true,
          onFullScreenToggle: _toggleFullScreen,
        ),
      ),
    );
  }

  Widget _buildNormalScreen() {
    final video = widget.videoModel;
    final String playPath = resolveVideoPath(video);

    return Scaffold(
      backgroundColor: kblack,
      appBar: AppBar(
        backgroundColor: kbg1black500,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: kwhite),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
             SizedBox(height: 10), const SizedBox(height: 12),
            CustomVideoPlayer(
              videoModel: video,
              videoPath: playPath,
              isFullScreen: false,
              onFullScreenToggle: _toggleFullScreen,
            ),

            const SizedBox(height: 10),
            Text(video.title,
                style: TextStyle(color: kwhite, fontSize: 20)),

            const SizedBox(height: 8),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.data_usage, color: kwhite300, size: 16),
                const SizedBox(width: 4),
                Text(video.size, style: TextStyle(color: kwhite300, fontSize: 13)),
                
                const SizedBox(width: 20),
                Icon(Icons.calendar_month, color: kwhite300, size: 16),
                const SizedBox(width: 4),
                Text(_dateText(video.date), style: TextStyle(color: kwhite300, fontSize: 13)),


              ],
            ),

            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                InkWell(
                  onTap: () => Share.share(
                      "Watch this video:\nhttps://filedock.in/${video.id}"),
                  child: _actionBtn("Share", Icons.share, Colors.white, Colors.black), // 🔥 High Contrast
                ),
                Obx(() {
                  bool isDownloading = downloadController.isDownloading(video.url);
                  double progress = downloadController.getProgress(video.url);

                  if (isDownloading) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      decoration: BoxDecoration(color: kbg2lightblack300, borderRadius: BorderRadius.circular(30)),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 20, 
                            height: 20, 
                            child: CircularProgressIndicator(value: progress, color: kblueaccent, strokeWidth: 2),
                          ),
                          const SizedBox(width: 10),
                          Text("${(progress * 100).toStringAsFixed(0)}%", style: TextStyle(color: kwhite, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    );
                  }

                  if (_isDownloaded) {
                     return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          decoration: BoxDecoration(color: Colors.green, borderRadius: BorderRadius.circular(30)),
                          child: Row(
                            children: const [
                              Icon(Icons.check_circle, color: Colors.white),
                              SizedBox(width: 8),
                              Text("Downloaded", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                            ],
                          ),
                        );
                  }

                  if (_isAdLoading) {
                     return Container(
                       padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                       decoration: BoxDecoration(color: kblueaccent, borderRadius: BorderRadius.circular(30)),
                       child: const SizedBox(
                         width: 24, height: 24,
                         child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                       ),
                     );
                  }

                  return InkWell(
                          onTap: () => _downloadWithAd(video),
                          child: _actionBtn("Download", Icons.download, kblueaccent, Colors.white), // 🔥 High Contrast
                        );
                }),
              ],
            ),

            const SizedBox(height: 14),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: NativeVideoAdCard(adKey: "videoplayerscreenNative"),
            ),
            const SizedBox(height: 14),
          ],
        ),
      ),
    );
  }

  Widget _actionBtn(String text, IconData icon, Color color, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12), // 📏 Increased padding
      decoration:
          BoxDecoration(color: color, borderRadius: BorderRadius.circular(30)), // 🎨 More rounded
      child: Row(
        children: [
          Icon(icon, color: textColor),
          const SizedBox(width: 8),
          Text(text, style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 16)),
        ],
      ),
    );
  }
}

////////////////////////////////////////////////////////////
/// CUSTOM VIDEO PLAYER
////////////////////////////////////////////////////////////

class CustomVideoPlayer extends StatefulWidget {
  final String videoPath;
  final VideoModel videoModel;
  final bool isFullScreen;
  final VoidCallback onFullScreenToggle;

  const CustomVideoPlayer({
    super.key,
    required this.videoPath,
    required this.videoModel,
    required this.isFullScreen,
    required this.onFullScreenToggle,
  });

  @override
  State<CustomVideoPlayer> createState() => _CustomVideoPlayerState();
}

class _CustomVideoPlayerState extends State<CustomVideoPlayer> {
  VideoPlayerController? _controller; // 🔥 Make nullable for delayed init
  bool _showControls = true;
  bool _countedView = false;
  // bool _isFullScreen = false; // ❌ Removed: State managed by parent
  bool _hasError = false; 
  String _errorMessage = "";
  Timer? _hideTimer;

  final videoController = Get.find<VideoController>();

  @override
  void initState() {
    super.initState();
      // 🔥 KEEP SCREEN ON WHILE VIDEO IS PLAYING
    WakelockPlus.enable();

    final path = widget.videoPath.trim();
    debugPrint("🎬 VideoPlayer Init: path=$path"); 

    // 🔥 DELAY to allow Ad resources to clear
    Future.delayed(const Duration(milliseconds: 7000), () {
      if (!mounted) return;
      _initializeVideo();
    });
    
    _startHideTimer();
  }

  void _initializeVideo() {
    debugPrint("🎬 VideoPlayer Attempting Init...");
    setState(() {
      _hasError = false;
      _errorMessage = "";
    });

    final path = widget.videoPath.trim();
    
    // Dispose previous if any
    _controller?.dispose();

    _controller = path.startsWith("http")
        ? VideoPlayerController.networkUrl(Uri.parse(path))
        : VideoPlayerController.file(File(path));

    _controller!.initialize().timeout(const Duration(seconds: 15), onTimeout: () {
      throw TimeoutException("Video source too slow or unreachable.");
    }).then((_) {
      debugPrint("✅ Video initialized successfully");
      if (!mounted) return;
      setState(() {
         _hasError = false;
      });
      _controller?.play(); 
      
      // Re-attach listener
      _controller!.addListener(() {
        if (!mounted) return;
        
        // 1. View Counting Logic
        if (_controller!.value.position.inSeconds >= 1 && !_countedView) {
          _countedView = true;
          videoController.countViewAndEarning(widget.videoModel);
        }

        // 2. Refresh UI for Seekbar & Time (Throttled if needed, but setState is fine)
        if (_controller!.value.isPlaying) {
          setState(() {}); 
        }
      });

    }).catchError((error) {
      debugPrint("❌ Video Init Error: $error");
      if (!mounted) return;
      setState(() {
        _hasError = true;
        _errorMessage = error.toString();
      });
    });
  }

  void _startHideTimer() {
    _hideTimer?.cancel();
    _hideTimer = Timer(const Duration(seconds: 7), () {
      if (mounted) setState(() => _showControls = false);
    });
  }

  // _toggleFullScreen, _isFullScreen REMOVED. Use widget.onFullScreenToggle and widget.isFullScreen

  @override
  @override
  void dispose() {
    WakelockPlus.disable();
    // SystemChrome... ❌ Removed: Handled by parent
    _controller?.dispose();
    _hideTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
       return Container(
          height: 220,
          color: Colors.black,
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
               const Icon(Icons.error, color: Colors.white, size: 40),
                SizedBox(height: 10),
               const Text("Video Failed to Load", style: TextStyle(color: Colors.white)),
               Text(_errorMessage, style: const TextStyle(color: Colors.white54, fontSize: 10), textAlign: TextAlign.center),
               const SizedBox(height: 15),
               ElevatedButton.icon(
                 onPressed: _initializeVideo,
                 icon: Icon(Icons.refresh),
                 label:  Text("Retry"),
               )
            ],
          ),
       );
    }

    // Checking if null or not initialized
    if (_controller == null || !_controller!.value.isInitialized) {
  return SizedBox(
    width: double.infinity,
    height: widget.isFullScreen
        ? MediaQuery.of(context).size.height
        : 220,
    child: const Center(
      child: CircularProgressIndicator(color: Colors.white),
    ),
  );
}




    

return Stack(
  alignment: Alignment.center,
  children: [
    GestureDetector(
      onTap: () {
        setState(() => _showControls = !_showControls);
        if (_showControls) _startHideTimer();
      },
  child: SizedBox(
  width: double.infinity,
  height: widget.isFullScreen
      ? MediaQuery.of(context).size.height
      : 220, // 🔥 FIXED HEIGHT FOR NORMAL MODE

  child: FittedBox(
    fit: BoxFit.contain, // ⭐ KEY: reel + normal both fit
    child: SizedBox(
      width: _controller!.value.size.width,
      height: _controller!.value.size.height,
      child: VideoPlayer(_controller!),
    ),
  ),
),

    ),

    // BUFFERING INDICATOR
    if (_controller!.value.isBuffering)
      const Center(
        child: CircularProgressIndicator(color: Colors.white),
      ),

    // CONTROLS OVERLAY
    if (_showControls && !_controller!.value.isBuffering)
      Container(
        color: Colors.transparent,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // TOP BAR
            Padding(
              padding: const EdgeInsets.only(top: 10, right: 10),
              child: Align(
                alignment: Alignment.topRight,
                child: IconButton(
                  icon: Icon(
                    widget.isFullScreen
                        ? Icons.fullscreen_exit
                        : Icons.fullscreen,
                    color: Colors.white,
                    size: 30,
                  ),
                  onPressed: widget.onFullScreenToggle,
                ),
              ),
            ),

            // CENTER CONTROLS
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.replay_10_rounded,
                      color: Colors.white, size: 36),
                  onPressed: () {
                    final pos = _controller!.value.position;
                    final target = pos - const Duration(seconds: 10);
                    _controller!.seekTo(
                        target < Duration.zero ? Duration.zero : target);
                    _startHideTimer();
                  },
                ),

                SizedBox(width: 30),

                IconButton(
                  icon: Icon(
                    _controller!.value.isPlaying
                        ? Icons.pause_circle_filled
                        : Icons.play_circle_fill,
                    size: 64,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    setState(() {
                      _controller!.value.isPlaying
                          ? _controller!.pause()
                          : _controller!.play();
                    });
                    _startHideTimer();
                  },
                ),

                 SizedBox(width: 30),

                IconButton(
                  icon: const Icon(Icons.forward_10_rounded,
                      color: Colors.white, size: 36),
                  onPressed: () {
                    final pos = _controller!.value.position;
                    final end = _controller!.value.duration;
                    final target = pos + const Duration(seconds: 10);
                    _controller!.seekTo(target > end ? end : target);
                    _startHideTimer();
                  },
                ),
              ],
            ),

            // BOTTOM SEEK BAR
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              child: Row(
                children: [
                  Text(
                    _formatDuration(_controller!.value.position),
                    style: const TextStyle(
                        color: Colors.white, fontSize: 12),
                  ),
                  Expanded(
                    child: Slider(
                      activeColor: kblueaccent,
                      inactiveColor: Colors.white24,
                      min: 0,
                      max: _controller!.value.duration.inSeconds.toDouble(),
                      value: _controller!.value.position.inSeconds
                          .toDouble()
                          .clamp(
                            0,
                            _controller!.value.duration.inSeconds
                                .toDouble(),
                          ),
                      onChanged: (val) {
                        _controller!
                            .seekTo(Duration(seconds: val.toInt()));
                        _startHideTimer();
                      },
                    ),
                  ),
                  Text(
                    _formatDuration(_controller!.value.duration),
                    style: const TextStyle(
                        color: Colors.white, fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
  ],
);



  }
  String _formatDuration(Duration d) {
    if (d.inHours > 0) {
       final hh = d.inHours.toString().padLeft(2, '0');
       final mm = (d.inMinutes % 60).toString().padLeft(2, '0');
       final ss = (d.inSeconds % 60).toString().padLeft(2, '0');
       return "$hh:$mm:$ss";
    }
    final mm = d.inMinutes.toString().padLeft(2, '0');
    final ss = (d.inSeconds % 60).toString().padLeft(2, '0');
    return "$mm:$ss";
  }
}

////////////////////////////////////////////////////////////
/// HELPER
////////////////////////////////////////////////////////////

String resolveVideoPath(VideoModel video) {
  if (video.localPath != null &&
      video.localPath!.isNotEmpty &&
      File(video.localPath!).existsSync()) {
    return video.localPath!;
  }
  return video.url;
}
