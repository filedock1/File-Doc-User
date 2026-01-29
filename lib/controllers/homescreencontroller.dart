import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:filedock_user/controllers/tabcontroller.dart';
import 'package:filedock_user/controllers/videocontroller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomeController extends GetxController {
  final linkController = TextEditingController();
  var isLoading = false.obs;

  final videoController = Get.put(VideoController());

  /// Receive from main.dart deep link handler
  void handleDeepLink(String videoId) {
    if (videoId.isEmpty) {
      Get.snackbar("Error", "Invalid video ID");
      return;
    }
    _fetchAndPlayVideo(videoId);
  }

  /// Manual input support
Future<void> handleLinkTap(String input) async {
  if (input.isEmpty) return;

  try {
    Uri? uri = Uri.tryParse(input.trim());

    String? videoId;

    // CASE → full link like: https://filedock.in/8XM1RPOJBY1TX9upBcHU
    if (uri != null && uri.host.contains("filedock.in")) {
      if (uri.pathSegments.isNotEmpty) {
        videoId = uri.pathSegments.last; // extract ID from link
      }
    }

    // CASE → raw ID only
    videoId ??= input.trim();

    if (videoId.isEmpty) {
      Get.snackbar("Error", "Invalid link format");
      return;
    }

    _fetchAndPlayVideo(videoId);

  } catch (e) {
    Get.snackbar("Error", "Invalid link format");
  }
}


  Future<void> _fetchAndPlayVideo(String videoId) async {
    isLoading.value = true;

    try {
      final doc = await FirebaseFirestore.instance
          .collection("videos")
          .doc(videoId)
          .get();

      if (!doc.exists) {
        Get.snackbar("Error", "Video not found");
        return;
      }

      videoController.setVideoData(
        id: videoId,
        url: doc["storageUrl"],
        title: doc["title"],
        size: "${(doc["size"] / (1024 * 1024)).toStringAsFixed(2)} MB",
        date: (doc["createdAt"] as Timestamp).toDate(),
        views: doc["views"] ?? 0,
        clickCount: doc["clickCount"] ?? 0,
      );

      Get.find<TabControllerX>().changeTab(1);

    } catch (e) {
      Get.snackbar("Error", "Something went wrong: $e");
    } finally {
      isLoading.value = false;
    }
  }
}
