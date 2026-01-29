import 'dart:io';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:media_store_plus/media_store_plus.dart';
import 'package:permission_handler/permission_handler.dart';

class DownloadController extends GetxController {
  final RxBool isDownloading = false.obs;
  final RxDouble progress = 0.0.obs;

  final MediaStore _mediaStore = MediaStore();

  /// Request storage permission
  Future<bool> _requestPermission() async {
    if (Platform.isAndroid) {
      if (await Permission.storage.isGranted ||
          await Permission.videos.isGranted) {
        return true;
      }
      final statuses = await [
        Permission.storage,
        Permission.videos,
      ].request();
      return statuses.values.any((status) => status.isGranted);
    }
    return true;
  }

  /// Download and save to gallery
  Future<void> downloadVideo(String url, String fileName) async {
    if (!await _requestPermission()) {
      Get.snackbar("Permission Denied", "Cannot save without storage access");
      return;
    }

    try {
      isDownloading.value = true;
      progress.value = 0.0;

      final request = http.Request('GET', Uri.parse(url));
      final response = await http.Client().send(request);

      final total = response.contentLength ?? 0;
      int received = 0;

      final tempDir = await getTemporaryDirectory();
      final tempPath = '${tempDir.path}/$fileName';
      final file = File(tempPath);
      final sink = file.openWrite();

      await for (final chunk in response.stream) {
        sink.add(chunk);
        received += chunk.length;
        if (total != 0) {
          progress.value = received / total;
        }
      }
      await sink.close();

      // ✅ Correct call for ^0.1.3
      await _mediaStore.saveFile(
        tempFilePath: tempPath,
        dirType: DirType.video,
        dirName: DirName.movies, // goes to Movies folder
      ).whenComplete(() {
        print("Download saved to gallary");
      },);

      Get.snackbar("Success", "Video saved to Gallery");
    } catch (e) {
      Get.snackbar("Error", "Download failed: $e");
    } finally {
      isDownloading.value = false;
      progress.value = 0.0;
    }
  }
}
