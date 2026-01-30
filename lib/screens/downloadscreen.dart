import 'dart:convert';
import 'dart:io';
import 'package:filedock_user/screens/videoplayerscreen.dart';
import 'package:filedock_user/controllers/downloadcontroller.dart'; // ✅ Import
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

import '../adwidgets/bannerad.dart';
import '../constant/colors.dart';
import '../model/videomodel.dart';

class DownloadScreen extends StatefulWidget {
  const DownloadScreen({super.key});

  @override
  State<DownloadScreen> createState() => _DownloadScreenState();
}

class _DownloadScreenState extends State<DownloadScreen> {
  List<FileSystemEntity> _downloadedFiles = [];
  Map<String, String?> _thumbnails = {}; // cache thumbnails

  @override
  void initState() {
    super.initState();
    _fetchDownloadedFiles();
  }

  Future<void> _fetchDownloadedFiles() async {
    // Use correct directory matching DownloadController
    final dir = Platform.isAndroid 
        ? await getExternalStorageDirectory() 
        : await getApplicationDocumentsDirectory();

    if (dir == null) return;
    
    debugPrint("📂 Scanning Directory: ${dir.path}");

    if (!await dir.exists()) {
      debugPrint("❌ Downloads folder not found");
      return;
    }

    final files = dir
        .listSync()
        .where((file) => file.path.endsWith(".mp4"))
        .toList();
        
    debugPrint("📂 Found ${files.length} .mp4 files");

    final now = DateTime.now();
    final cutoffDate = now.subtract(const Duration(days: 15));

    List<FileSystemEntity> recentFiles = [];

    for (var file in files) {
      debugPrint("📄 Processing: ${file.path}");
      try {
        final stat = await File(file.path).stat();
        if (stat.modified.isAfter(cutoffDate)) {
          recentFiles.add(file);
          // Don't await thumbnail generation to speed up UI
          _generateThumbnail(file.path).then((_){ setState((){}); });
        } else {
             debugPrint("🗑 Can delete old file (Skipped for now logic)");
             // optionally delete
             recentFiles.add(file); // 🔥 Show them anyway for now to debug
        }
      } catch (e) {
        debugPrint("⚠️ Error reading file stats: $e");
        recentFiles.add(file); // Fallback: add it
      }
    }

    setState(() {
      _downloadedFiles = recentFiles;
    });
  }

  Future<void> _generateThumbnail(String videoPath) async {
    final thumb = await VideoThumbnail.thumbnailFile(
      video: videoPath,
      thumbnailPath: (await getTemporaryDirectory()).path,
      imageFormat: ImageFormat.PNG,
      maxHeight: 120,
      quality: 75,
    );

    setState(() {
      _thumbnails[videoPath] = thumb;
    });
  }

  Future<void> _deleteFile(FileSystemEntity fileObj) async {
    bool confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: kbg2lightblack300,
        title: const Text("Delete Video?", style: TextStyle(color: Colors.white)),
        content: const Text("Are you sure you want to delete this downloaded video?", style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text("Delete", style: TextStyle(color: kblueaccent)),
          ),
        ],
      ),
    ) ?? false;

    if (!confirm) return;

    try {
      if (fileObj is File) {
        await fileObj.delete();
        // Also try to delete metadata json
        final metaPath = fileObj.path.replaceAll(".mp4", ".json");
        final metaFile = File(metaPath);
        if (await metaFile.exists()) {
          await metaFile.delete();
        }
      }
      Get.snackbar("Deleted", "Video removed successfully");
      _fetchDownloadedFiles(); // Refresh list
    } catch (e) {
      Get.snackbar("Error", "Failed to delete: $e");
    }
  }


  @override
  Widget build(BuildContext context) {
    final downloadController = Get.put(DownloadController(), permanent: true); // ✅ Find Controller
    return Scaffold(
      backgroundColor: kblack,
      appBar: AppBar(
        backgroundColor: kbg1black500,
      toolbarHeight: 1,
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
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CustomBannerAd(bannerKey: 'downloadscreen_banner1'),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Downloaded files',
                          style: TextStyle(
                            color: kwhite,
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Montserrat-SemiBold',
                          ),
                        ),
                        const SizedBox(width: 6),
                        SvgPicture.asset(
                          'assets/svgicon/download-01.svg',
                          color: kwhite,
                          height: 24,
                          width: 24,
                        ),
                      ],
                    ),
                    GestureDetector(
                      onTap: _fetchDownloadedFiles, // refresh
                      child: SvgPicture.asset(
                        'assets/svgicon/refresh.svg',
                        height: 24,
                        width: 24,
                      ),
                    ),
                  ],
                ),
                
                // ⬇️ Active Downloads Section ⬇️
                Obx(() {
                  final downloading = downloadController.activeDownloads;
                  if (downloading.isEmpty) return const SizedBox.shrink();

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 12),
                      const Text("Downloading...", style: TextStyle(color: Colors.white70, fontSize: 14)),
                      const SizedBox(height: 8),
                      ...downloading.values.map((video) {
                        double progress = downloadController.getProgress(video.url);
                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: kbg2lightblack300,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.white10),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.downloading, color: kblueaccent, size: 24),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(video.title, style: const TextStyle(color: Colors.white, fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis),
                                    const SizedBox(height: 6),
                                    LinearProgressIndicator(value: progress, backgroundColor: Colors.white10, color: kblueaccent, minHeight: 4),
                                    const SizedBox(height: 4),
                                    Text("${(progress * 100).toStringAsFixed(0)}%", style: const TextStyle(color: Colors.white54, fontSize: 11)),
                                  ],
                                ),
                              ),
                              // ⏯️ Pause / Resume Toggle
                              Obx(() {
                                bool isPaused = downloadController.isPaused(video.url);
                                return IconButton(
                                  icon: Icon(
                                    isPaused ? Icons.play_arrow : Icons.pause, 
                                    color: isPaused ? Colors.greenAccent : Colors.amber
                                  ),
                                  onPressed: () {
                                    if (isPaused) {
                                      downloadController.resumeDownload(video);
                                    } else {
                                      downloadController.pauseDownload(video);
                                    }
                                  },
                                );
                              }), 
                              // ❌ Cancel/Delete Button
                              IconButton(
                                icon: const Icon(Icons.close, color: Colors.redAccent),
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      backgroundColor: kbg2lightblack300,
                                      title: const Text("Cancel Download?", style: TextStyle(color: Colors.white)),
                                      content: const Text(
                                        "This will stop the download and delete the partial file. Are you sure?", 
                                        style: TextStyle(color: Colors.white70)
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Get.back(), 
                                          child: const Text("No", style: TextStyle(color: Colors.white54))
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            downloadController.cancelDownload(video);
                                            Get.back();
                                          }, 
                                          child: const Text("Yes, Delete", style: TextStyle(color: Colors.redAccent))
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                      const Divider(color: Colors.white12),
                    ],
                  );
                }),
                // ⬆️ End Active Downloads ⬆️

                const SizedBox(height: 12),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.transparent, // ✨ Transparent to show dark background
                    ),
                    child: _downloadedFiles.isEmpty
                        ? Center(
                            child: Text(
                              "No downloads yet",
                              style: TextStyle(color: kblack, fontSize: 16),
                            ),
                          )
                        : GridView.builder(
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 3,
                                  crossAxisSpacing: 8,
                                  mainAxisSpacing: 8,
                                ),
                            itemCount: _downloadedFiles.length,
                            itemBuilder: (context, index) {
                              final file = _downloadedFiles[index];
                              final thumbPath = _thumbnails[file.path];

                                return GestureDetector(
                                onTap: () async {
                                  final metaFile = File(file.path.replaceAll(".mp4", ".json"));
                                  if (await metaFile.exists()) {
                                    final jsonStr = await metaFile.readAsString();
                                    final video = VideoModel.fromJson(jsonDecode(jsonStr));
                                    final localVideo = video.copyWith(url: file.path);
                                    Get.to(() => VideoPlayerScreen(videoModel: localVideo));
                                  }
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: kbg2lightblack300,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: Colors.white10),
                                  ),
                                  child: Stack(
                                    children: [
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.stretch,
                                        children: [
                                          Expanded(
                                            child: ClipRRect(
                                              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                                              child: thumbPath != null
                                                  ? Image.file(File(thumbPath), fit: BoxFit.cover)
                                                  : Container(
                                                      color: Colors.black,
                                                      child: const Icon(Icons.play_circle_outline, color: Colors.white54, size: 40),
                                                    ),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Row(
                                              children: [
                                                const Icon(Icons.video_file, color: Colors.white70, size: 14),
                                                const SizedBox(width: 4),
                                                Expanded(
                                                  child: Text(
                                                    file.path.split('/').last.replaceAll(".mp4", "").replaceAll("_", " "),
                                                    style: const TextStyle(color: Colors.white, fontSize: 11),
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      // 🗑️ Delete Button
                                      Positioned(
                                        top: 4,
                                        right: 4,
                                        child: InkWell(
                                          onTap: () => _deleteFile(file),
                                          child: Container(
                                            padding: const EdgeInsets.all(4),
                                            decoration: BoxDecoration(
                                              color: Colors.black54,
                                              shape: BoxShape.circle,
                                            ),
                                            child: const Icon(Icons.delete, color: Colors.redAccent, size: 18),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
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
