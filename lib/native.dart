import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class NativeAdBox extends StatefulWidget {
  const NativeAdBox({super.key});

  @override
  State<NativeAdBox> createState() => _NativeAdBoxState();
}

class _NativeAdBoxState extends State<NativeAdBox> {
  NativeAd? _ad;
  bool loaded = false;

  @override
  void initState() {
    super.initState();
    _loadAd();
  }

  void _loadAd() {

    _ad = NativeAd(
      adUnitId: "ca-app-pub-2091017524613192/7697381673",
      factoryId: "listTile", // MUST MATCH
      request: const AdRequest(),
      listener: NativeAdListener(
        onAdLoaded: (ad) {
          setState(() => loaded = true);
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
        },
      ),
    );


    _ad!.load();
  }

  @override
  Widget build(BuildContext context) {
    if (!loaded) return const SizedBox();

    return SizedBox(
      height: 120,
      child: AdWidget(ad: _ad!),
    );
  }

  @override
  void dispose() {
    _ad?.dispose();
    super.dispose();
  }
}
