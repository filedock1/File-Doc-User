import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shimmer/shimmer.dart';

import '../controllers/banneradcontroller.dart';

class CustomBannerAd extends StatefulWidget {
  final String bannerKey;
  final double borderRadius;
  final VoidCallback? onAdLoaded; // ✅ Callback

  const CustomBannerAd({
    Key? key,
    required this.bannerKey,
    this.borderRadius = 0,
    this.onAdLoaded,
  }) : super(key: key);

  @override
  State<CustomBannerAd> createState() => _CustomBannerAdState();
}

class _CustomBannerAdState extends State<CustomBannerAd> {
  final adController = Get.put(BannerAdController(), permanent: true);
  bool _callbackFired = false; // 🔒 Ensure fired once

  @override
  void initState() {
    super.initState();
    // Load a standard banner ad
    adController.loadBannerAd(widget.bannerKey, adSize: AdSize.banner);
  }

  @override
  void dispose() {
    // Free the ad resource to prevent invalid background impressions
    adController.disposeBannerAd(widget.bannerKey);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isError = adController.isBannerError(widget.bannerKey).value;
      final isLoaded = adController.isBannerLoaded(widget.bannerKey).value;

      // 🔥 Notify parent if ad is done (success or error)
      if ((isError || isLoaded) && !_callbackFired) {
        _callbackFired = true;
        if (widget.onAdLoaded != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            widget.onAdLoaded!();
          });
        }
      }

      // 🔹 Show fallback if error (No fill / Failed)
      if (isError) {
        final errorMsg = adController.getErrorMessage(widget.bannerKey).value;
        return Container(
          width: AdSize.banner.width.toDouble(),
          height: AdSize.banner.height.toDouble(),
          decoration: BoxDecoration(
            color: Colors.grey.shade900,
            borderRadius: BorderRadius.circular(widget.borderRadius),
            border: Border.all(color: Colors.grey.shade800),
          ),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.ad_units, color: Colors.grey, size: 20),
                  const SizedBox(height: 4),
                  Text(
                    errorMsg.isNotEmpty ? errorMsg : "Ad unavailable",
                    style: const TextStyle(color: Colors.grey, fontSize: 10),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        );
      }

      if (!isLoaded) {
        // 🔹 Shimmer effect placeholder
        return Shimmer.fromColors(
          baseColor: Colors.grey.shade800,
          highlightColor: Colors.grey.shade600,
          child: Container(
            width: AdSize.banner.width.toDouble(),
            height: AdSize.banner.height.toDouble(),
            decoration: BoxDecoration(
              color: Colors.grey.shade900,
              borderRadius: BorderRadius.circular(widget.borderRadius),
            ),
          ),
        );
      }

      // 🔹 Show real ad
      return SizedBox(
        width: AdSize.banner.width.toDouble(),
        height: AdSize.banner.height.toDouble(),
        child: AdWidget(ad: adController.getBanner(widget.bannerKey)!),
      );
    });
  }
}
