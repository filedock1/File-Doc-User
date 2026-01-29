import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

import '../model/videomodel.dart';

class AdCountdownScreen extends StatefulWidget {
  final VideoModel video;

  const AdCountdownScreen({super.key, required this.video});

  @override
  State<AdCountdownScreen> createState() => _AdCountdownScreenState();
}

class _AdCountdownScreenState extends State<AdCountdownScreen> {
  int _seconds = 20;
  Timer? _timer;

  @override
  void initState() {
    super.initState();

    // Start download in background
    _startDownload();

    // Countdown timer
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_seconds > 0) {
        setState(() => _seconds--);
      } else {
        timer.cancel();
        // Auto close Ad screen after countdown
        Get.back();
      }
    });
  }

  Future<void> _downloadVideo(VideoModel video) async {
    try {
      final request = http.Request("GET", Uri.parse(video.url));
      final response = await http.Client().send(request);

      if (response.statusCode == 200) {
        final contentLength = response.contentLength ?? 0;
        final dir = await getApplicationDocumentsDirectory();

        // Save video file
        // Remove ".mp4" from title if already present
        String cleanTitle = video.title.replaceAll(" ", "_");
        if (cleanTitle.toLowerCase().endsWith(".mp4")) {
          cleanTitle = cleanTitle.substring(0, cleanTitle.length - 4);
        }

        final videoPath = "${dir.path}/$cleanTitle.mp4";
        final metaPath = "${dir.path}/$cleanTitle.json";

        final file = File(videoPath);
        final sink = file.openWrite();

        int downloaded = 0;
        await response.stream.listen((chunk) {
          downloaded += chunk.length;
          sink.add(chunk);
        }).asFuture();
        await sink.close();

        // Save metadata JSON ✅ (use jsonEncode)
        final metaFile = File(metaPath);
        await metaFile.writeAsString(jsonEncode(video.toJson()));

        Get.snackbar("Download Complete", "Saved to Documents folder");
      } else {
        Get.snackbar("Error", "Failed to download: ${response.statusCode}");
      }
    } catch (e) {
      Get.snackbar("Error", "Failed to download video");
    }
  }

  Future<void> _startDownload() async {
    // Call your existing function here
    await _downloadVideo(widget.video);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false, // ❌ Disable back button
      child: Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Banner
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 12,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Row(
                        children: [
                          const Text(
                            "Download will start after the ad",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 8),
                          CircleAvatar(
                            radius: 14,
                            backgroundColor: Colors.green,
                            child: Text(
                              '$_seconds',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Ad Image
              Expanded(
                child: Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.asset(
                      width: 390,
                      height: 263,
                      "assets/images/downloadadd.jpg",
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

}
