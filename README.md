# filedock_user

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

# Production Deployment Checklist

Follow these steps when you are ready to upload to the Play Store.

## 1. Final AdMob Switch (CRITICAL)
- [ ] Open `lib/admanager/admanager.dart`.
- [ ] Change `isTestMode` to `false`:
  ```dart
  static const bool isTestMode = false; 
  ```
- [ ] Ensure **Real Ad Unit IDs** are in your Firebase Remote Config (or the default JSON in `AdManager.dart`).

## 2. Generate Release Build
- [ ] Open terminal in project root.
- [ ] Run:
  ```bash
  flutter clean
  flutter build appbundle --release
  ```
- [ ] The file will be at: `build/app/outputs/bundle/release/app-release.aab`.

## 3. Upload to Play Console
- [ ] Create a new **Production Release**.
- [ ] Upload the `app-release.aab` file.
- [ ] Note: If `flutter build` fails with signing errors, ensure `key.properties` and `upload-keystore.jks` are in `android/app/`.

## 4. Post-Release
- [ ] Verify `app-ads.txt` on your website includes your AdMob ID.
- [ ] Check Firebase Crashlytics for any strict-mode crashes.
