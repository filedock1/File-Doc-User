import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart'; // ✅ for Timestamp
import 'package:flutter/foundation.dart'; // ✅ for debugPrint

class VideoModel {
  final String id;
  final String url;       // original network URL
  final String? localPath; // optional: downloaded file path
  final String title;
  final int views;
  final int clickCount;
  final String size;
  final DateTime date;

  VideoModel({
    required this.id,
    required this.url,
    this.localPath,
    required this.title,
    required this.views,
    required this.clickCount,
    required this.size,
    required this.date,
  });

  VideoModel copyWith({
    String? id,
    String? url,
    String? localPath,
    String? title,
    int? views,
    int? clickCount,
    String? size,
    DateTime? date,
  }) {
    return VideoModel(
      id: id ?? this.id,
      url: url ?? this.url,
      localPath: localPath ?? this.localPath,
      title: title ?? this.title,
      views: views ?? this.views,
      clickCount: clickCount ?? this.clickCount,
      size: size ?? this.size,
      date: date ?? this.date,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'url': url,
    'localPath': localPath,
    'title': title,
    'views': views,
    'clickCount': clickCount,
    'size': size,
    'date': date.toIso8601String(),
  };

  factory VideoModel.fromJson(Map<String, dynamic> json) {
    final urlVal = json['url']?.toString();
    final storageVal = json['storageUrl']?.toString();
    debugPrint("🔍 VideoModel Parsing: url=$urlVal, storageUrl=$storageVal");

    // 1. Parse Date (Handle String vs Timestamp)
    DateTime parsedDate = DateTime.now();
    try {
      var dateVal = json['date'] ?? json['createdAt'] ?? json['timestamp'];

      if (dateVal is Timestamp) {
        parsedDate = dateVal.toDate();
      } else if (dateVal is String) {
        parsedDate = DateTime.tryParse(dateVal) ?? DateTime.now();
      }
    } catch (e) {
      debugPrint("⚠️ Date parsing failed: $e");
    }

    // 2. Parse & Format Size (Handle raw bytes)
    String rawSize = json['size']?.toString() ?? '';
    String formattedSize = rawSize;
    if (RegExp(r'^\d+$').hasMatch(rawSize)) {
      // It's a number (bytes), let's format it
      final bytes = int.tryParse(rawSize) ?? 0;
      if (bytes > 0) {
        const suffixes = ["B", "KB", "MB", "GB", "TB"];
        var i = 0;
        double dBytes = bytes.toDouble();
        while (dBytes >= 1024 && i < suffixes.length - 1) {
          dBytes /= 1024;
          i++;
        }
        formattedSize = "${dBytes.toStringAsFixed(1)} ${suffixes[i]}";
      }
    }

    return VideoModel(
      id: json['id']?.toString() ?? '',
      url: urlVal ?? storageVal ?? '',
      localPath: json['localPath']?.toString(),
      title: json['title']?.toString() ?? '',
      views: (json['views'] is int)
          ? json['views']
          : int.tryParse('${json['views']}') ?? 0,
      clickCount: (json['clickCount'] is int)
          ? json['clickCount']
          : int.tryParse('${json['clickCount']}') ?? 0,
      size: formattedSize,
      date: parsedDate,
    );
  }

  static VideoModel fromJsonString(String jsonStr) =>
      VideoModel.fromJson(jsonDecode(jsonStr));

  String toJsonString() => jsonEncode(toJson());

  bool canAddClick(int currentDeviceClicks) {
    return currentDeviceClicks < 8;
  }

  String getClickStatus(int currentDeviceClicks) {
    if (currentDeviceClicks >= 8) {
      return "Click limit reached (8 max)";
    }
    return "${8 - currentDeviceClicks} clicks remaining";
  }
  static VideoModel clear() {
    return VideoModel(
      id: '',
      url: '',
      title: '',
      views: 0,
      clickCount: 0,
      size: '',
      date: DateTime.now(),
    );
  }
}