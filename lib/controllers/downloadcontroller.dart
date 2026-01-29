import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'dart:ui';

import 'package:device_info_plus/device_info_plus.dart'; // ✅ Device Info
import 'package:filedock_user/model/videomodel.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart'; // ✅ Required for EdgeInsets
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart'; // ✅ Permissions
import 'package:vision_gallery_saver/vision_gallery_saver.dart';

class DownloadController extends GetxController {
  // Observables for UI
  var progressMap = <String, double>{}.obs;
  var downloadingMap = <String, bool>{}.obs; // true if running or enqueued
  var pausedMap = <String, bool>{}.obs;
  var activeDownloads = <String, VideoModel>{}.obs;
  
  // Internal: Map URL -> TaskId
  final Map<String, String> _urlToTaskId = {};
  // Internal: Map TaskId -> URL
  final Map<String, String> _taskIdToUrl = {};

  final ReceivePort _port = ReceivePort();
  Timer? _syncTimer;

  @override
  void onInit() {
    super.onInit();
    
    // Register Port
    IsolateNameServer.registerPortWithName(_port.sendPort, 'downloader_send_port');
    _port.listen((dynamic data) {
      String id = data[0];
      int status = data[1];
      int progress = data[2];
      _handleDownloadUpdate(id, status, progress);
    });
    
    FlutterDownloader.registerCallback(downloadCallback);

    // Initial Sync
    _syncTasks();
  }

  @override
  void onClose() {
    IsolateNameServer.removePortNameMapping('downloader_send_port');
    _syncTimer?.cancel();
    super.onClose();
  }

  // Polling Fallback to ensure UI updates even if Port fails
  void _startPolling() {
    _syncTimer?.cancel();
    _syncTimer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      if (activeDownloads.isEmpty) {
        timer.cancel();
      } else {
        _syncTasks();
      }
    });
  }

  Future<void> _syncTasks() async {
    final tasks = await FlutterDownloader.loadTasks();
    if (tasks == null) return;

    for (var task in tasks) {
        // If we have this task in our active list or maps, update it
        if (_taskIdToUrl.containsKey(task.taskId)) {
             _handleDownloadUpdate(task.taskId, task.status.index, task.progress); // ✅ .index NOT .value
        } else if (task.status == DownloadTaskStatus.running || task.status == DownloadTaskStatus.enqueued) {
            // Found a running task not in our map? (Maybe from restart)
            // We can't easily recover VideoModel without persistence, but for now just update if mapped.
        }
    }
  }

  void _handleDownloadUpdate(String taskId, int status, int progress) {
    final url = _taskIdToUrl[taskId];
    if (url == null) return;

    // Update Progress
    if (progress >= 0) {
      progressMap[url] = progress / 100.0;
    }

    // Convert Status safely
    DownloadTaskStatus taskStatus;
    try {
      taskStatus = DownloadTaskStatus.values[status];
    } catch (e) {
      taskStatus = DownloadTaskStatus.undefined;
    }

    if (taskStatus == DownloadTaskStatus.running || taskStatus == DownloadTaskStatus.enqueued) {
      downloadingMap[url] = true;
      pausedMap[url] = false;
      // Ensure polling is running
      if (_syncTimer == null || !_syncTimer!.isActive) _startPolling();
      
    } else if (taskStatus == DownloadTaskStatus.paused) {
      downloadingMap[url] = false;
      pausedMap[url] = true;
    } else if (taskStatus == DownloadTaskStatus.complete) {
      _onDownloadComplete(url, taskId);
    } else if (taskStatus == DownloadTaskStatus.failed || taskStatus == DownloadTaskStatus.canceled) {
      downloadingMap[url] = false;
      pausedMap[url] = false;
      activeDownloads.remove(url);
      progressMap.remove(url);
      
      _urlToTaskId.remove(url);
      _taskIdToUrl.remove(taskId);
      
      if (taskStatus == DownloadTaskStatus.failed) {
        // Get.snackbar("Error", "Download failed for $url"); // Optional: Verify needed
      }
    }
  }

  Future<void> _onDownloadComplete(String url, String taskId) async {
     downloadingMap[url] = false;
     activeDownloads.remove(url);
     progressMap.remove(url);
     
     _urlToTaskId.remove(url);
     _taskIdToUrl.remove(taskId);

     Get.snackbar("Success", "Download Completed", snackPosition: SnackPosition.BOTTOM, margin: const EdgeInsets.all(10));
  }


  Future<void> startDownload(VideoModel video) async {
    if (downloadingMap[video.url] == true) return;

    try {
      // Permission Handling (Simplified for Reliability)
      if (Platform.isAndroid) {
        final androidInfo = await DeviceInfoPlugin().androidInfo;
        if (androidInfo.version.sdkInt >= 33) {
           var notif = await Permission.notification.status;
           if (notif.isDenied) await Permission.notification.request();
        } else {
          var status = await Permission.storage.status;
          if (!status.isGranted) await Permission.storage.request();
        }
      }

      final dir = Platform.isAndroid 
          ? await getExternalStorageDirectory() 
          : await getApplicationDocumentsDirectory();
          
      if (dir == null) return; // Fail silently or show generic error

      String name = video.title.replaceAll(" ", "_");
      if (!name.endsWith(".mp4")) name = "$name.mp4";
      
      final saveDir = dir.path;
      final file = File("$saveDir/$name");

      // Ensure directory exists
      await Directory(saveDir).create(recursive: true);

      downloadingMap[video.url] = true;
      pausedMap[video.url] = false;
      activeDownloads[video.url] = video;
      progressMap[video.url] = 0.0;

      // Save Metadata
      final metaPath = "$saveDir/${name.replaceAll(".mp4", ".json")}";
      await File(metaPath).writeAsString(jsonEncode({
          ...video.toJson(),
          "localPath": file.path,
      }));

      final taskId = await FlutterDownloader.enqueue(
        url: video.url,
        savedDir: saveDir,
        fileName: name,
        showNotification: true, 
        openFileFromNotification: true, 
        saveInPublicStorage: false, // 🔥 FALSE: Save to App Directory so we can see it
      );

      if (taskId != null) {
        _urlToTaskId[video.url] = taskId;
        _taskIdToUrl[taskId] = video.url;
        _startPolling(); // 🔥 Start Polling immediately
      } else {
        downloadingMap[video.url] = false;
        activeDownloads.remove(video.url);
      }
      
    } catch (e) {
      Get.snackbar("Error", e.toString());
      downloadingMap[video.url] = false;
      activeDownloads.remove(video.url);
    }
  }

  Future<void> pauseDownload(VideoModel video) async {
    final taskId = _urlToTaskId[video.url];
    if (taskId != null) {
      await FlutterDownloader.pause(taskId: taskId);
      _syncTasks(); // Force sync
    }
  }

  Future<void> resumeDownload(VideoModel video) async {
     final taskId = _urlToTaskId[video.url];
     if (taskId != null) {
       final newTaskId = await FlutterDownloader.resume(taskId: taskId);
       
       if (newTaskId != null) {
          // Update Maps with new ID
          _urlToTaskId[video.url] = newTaskId;
          _taskIdToUrl[newTaskId] = video.url;
          
          // Clean old ID mapping locally (optional but cleaner)
          if (newTaskId != taskId) _taskIdToUrl.remove(taskId);
          
          _startPolling();
       } else {
         // Resume failed? Maybe restart
         startDownload(video);
       }
     } else {
       startDownload(video);
     }
  }

  Future<void> cancelDownload(VideoModel video) async {
    final taskId = _urlToTaskId[video.url];
    if (taskId != null) {
      await FlutterDownloader.cancel(taskId: taskId);
      // Clean up maps will happen in update/sync
      _syncTasks();
    }
  }

  bool isDownloading(String url) => downloadingMap[url] ?? false;
  bool isPaused(String url) => pausedMap[url] ?? false;
  double getProgress(String url) => progressMap[url] ?? 0.0;
}

// 🔥 Top-Level Callback
@pragma('vm:entry-point')
void downloadCallback(String id, int status, int progress) {
  final SendPort? send = IsolateNameServer.lookupPortByName('downloader_send_port');
  send?.send([id, status, progress]);
}
