package com.ignito.filedockuser

import android.media.MediaScannerConnection
import android.net.Uri
import android.os.Environment
import androidx.annotation.NonNull
import android.view.LayoutInflater
import android.widget.Button
import android.widget.TextView
import com.google.android.gms.ads.nativead.MediaView
import com.google.android.gms.ads.nativead.NativeAd
import com.google.android.gms.ads.nativead.NativeAdView
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.googlemobileads.GoogleMobileAdsPlugin

class MainActivity: FlutterActivity() {
    private val CHANNEL = "filedock_user/channel"

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // Register native ad factory
        GoogleMobileAdsPlugin.registerNativeAdFactory(
            flutterEngine,
            "listTile",
            ListTileNativeAdFactory(layoutInflater)
        )

        // Setup MethodChannel for MediaScanner
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler {
            call, result ->
            when (call.method) {
                "scanFile" -> {
                    val path = call.argument<String>("path")
                    if (path != null) {
                        scanFile(path, result)
                    } else {
                        result.error("ERROR", "Path is null", null)
                    }
                }
                else -> result.notImplemented()
            }
        }
    }

    override fun cleanUpFlutterEngine(flutterEngine: FlutterEngine) {
        super.cleanUpFlutterEngine(flutterEngine)
        GoogleMobileAdsPlugin.unregisterNativeAdFactory(flutterEngine, "listTile")
    }

    private fun scanFile(path: String, result: MethodChannel.Result) {
        try {
            MediaScannerConnection.scanFile(
                this,
                arrayOf(path),
                null,
                MediaScannerConnection.OnScanCompletedListener { scannedPath, uri ->
                    if (uri != null) {
                        result.success("File scanned successfully: $scannedPath")
                    } else {
                        result.error("ERROR", "Failed to scan file: $scannedPath", null)
                    }
                }
            )
        } catch (e: Exception) {
            result.error("ERROR", "MediaScanner error: ${e.message}", null)
        }
    }
}

class ListTileNativeAdFactory(private val inflater: LayoutInflater) :
    GoogleMobileAdsPlugin.NativeAdFactory {

    override fun createNativeAd(
        nativeAd: NativeAd,
        customOptions: MutableMap<String, Any>?
    ): NativeAdView {

        val adView = inflater.inflate(R.layout.native_ad_listtile, null) as NativeAdView

        // Headline
        val headlineView = adView.findViewById<TextView>(R.id.ad_headline)
        headlineView.text = nativeAd.headline
        adView.headlineView = headlineView

        // Body
        val bodyView = adView.findViewById<TextView>(R.id.ad_body)
        if (nativeAd.body != null) {
            bodyView.text = nativeAd.body
            bodyView.visibility = android.view.View.VISIBLE
        } else {
            bodyView.visibility = android.view.View.GONE
        }
        adView.bodyView = bodyView

        // Icon
        val iconView = adView.findViewById<android.widget.ImageView>(R.id.ad_app_icon)
        if (nativeAd.icon != null) {
            iconView.setImageDrawable(nativeAd.icon?.drawable)
            iconView.visibility = android.view.View.VISIBLE
        } else {
            iconView.visibility = android.view.View.GONE
        }
        adView.iconView = iconView

        // Advertiser ✅ (THIS MUST BE INSIDE FUNCTION)
        val advertiserView = adView.findViewById<TextView>(R.id.ad_advertiser)
        if (nativeAd.advertiser != null) {
            advertiserView.text = nativeAd.advertiser
            advertiserView.visibility = android.view.View.VISIBLE
            adView.advertiserView = advertiserView
        } else {
            advertiserView.visibility = android.view.View.GONE
        }

        // Attach ad
        adView.setNativeAd(nativeAd)

        return adView
    }
}
