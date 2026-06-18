#!/usr/bin/env bash
# Production release builds for Nova Heronix WiFi Manager.
# Builds Android from /tmp to avoid macOS AppleDouble (._*) issues on external volumes.

set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
BUILD_DIR="${BUILD_DIR:-/tmp/nova_heronix_build}"
RELEASE_DIR="$ROOT/release"
export COPYFILE_DISABLE=1

echo "==> Removing macOS AppleDouble (._*) files from project"
find "$ROOT" -name '._*' -delete 2>/dev/null || true

echo "==> Syncing project to $BUILD_DIR"
rm -rf "$BUILD_DIR"
mkdir -p "$RELEASE_DIR/android" "$RELEASE_DIR/ios"

rsync -a \
  --exclude build \
  --exclude .dart_tool \
  --exclude ios/Pods \
  --exclude ios/.symlinks \
  --exclude android/.gradle \
  --exclude '**/._*' \
  "$ROOT/" "$BUILD_DIR/"

find "$BUILD_DIR" -name '._*' -delete 2>/dev/null || true

cd "$BUILD_DIR"
flutter pub get

echo "==> Android: App Bundle (Play Store)"
flutter build appbundle --release

echo "==> Android: APK (direct install)"
flutter build apk --release

mkdir -p "$RELEASE_DIR/android"
cp build/app/outputs/bundle/release/app-release.aab "$RELEASE_DIR/android/"
cp build/app/outputs/flutter-apk/app-release.apk "$RELEASE_DIR/android/"

echo "==> iOS: IPA (App Store / TestFlight)"
cd ios && pod install && cd ..
if flutter build ipa --release --export-options-plist=ios/ExportOptions.plist; then
  mkdir -p "$RELEASE_DIR/ios"
  cp build/ios/ipa/*.ipa "$RELEASE_DIR/ios/" 2>/dev/null || \
    find build/ios -name '*.ipa' -exec cp {} "$RELEASE_DIR/ios/" \;
else
  echo "WARN: iOS IPA build failed. Install iOS platform in Xcode > Settings > Components,"
  echo "      then run: flutter build ipa --release --export-options-plist=ios/ExportOptions.plist"
fi

echo ""
echo "Release artifacts:"
ls -lh "$RELEASE_DIR/android/" 2>/dev/null || true
ls -lh "$RELEASE_DIR/ios/" 2>/dev/null || true
echo "Done."
