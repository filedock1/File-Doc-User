import 'package:filedock_user/controllers/nativeadcontroller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shimmer/shimmer.dart';

class NativeVideoAdCard extends StatefulWidget {
  final String adKey;
  final double height;
  final VoidCallback? onAdLoaded; // ✅ Callback

  const NativeVideoAdCard({
    Key? key,
    required this.adKey,
    this.height = 260,
    this.onAdLoaded,
  }) : super(key: key);

  @override
  State<NativeVideoAdCard> createState() => _NativeVideoAdCardState();
}

class _NativeVideoAdCardState extends State<NativeVideoAdCard> {
  late NativeAdController adController;
  bool _callbackFired = false; // 🔒 Ensure fired once

  @override
  void initState() {
    super.initState();
    // Unique controller for this specific adKey
    adController = Get.put(NativeAdController(), tag: widget.adKey);
    adController.loadNativeAd(widget.adKey);
  }

  // Optional: Dispose/Delete controller when widget is removed?
  // Since we used permanent: false (default), it might be auto-deleted if no one listens?
  // But Get.put creates it. We should probably let it live or manually delete.
  // For now, let's leave it. If screen is popped, we might want to keep it? 
  // Actually, standard practice for Ads is to dispose. 
  // Let's rely on adController.onClose() which disposes the ad. 
  
  @override
  void dispose() {
    // Determine if we should delete the controller to free resources
    // Get.delete<NativeAdController>(tag: widget.adKey);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isError = adController.isError.value;
      final isLoaded = adController.isLoaded.value;

      // 🔥 Notify parent if ad is done (success or error)
      if ((isError || isLoaded) && !_callbackFired) {
        _callbackFired = true;
        if (widget.onAdLoaded != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
             widget.onAdLoaded!();
          });
        }
      }

      // 🔹 Hide if error
      if (isError) {
        return const SizedBox.shrink();
      }

      if (!isLoaded) {
        // 🔹 Shimmer placeholder while loading
        return Shimmer.fromColors(
          baseColor: Colors.grey.shade800,
          highlightColor: Colors.grey.shade600,
          child: Container(
            height: widget.height,
            margin: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: Colors.grey.shade900,
            ),
          ),
        );
      }

      // 🔹 Show real native ad once loaded
      return SizedBox(
        height: widget.height,
        child: AdWidget(ad: adController.nativeAd!),
      );
    });
  }
}
