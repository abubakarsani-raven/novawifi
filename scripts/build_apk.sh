#!/usr/bin/env bash
# Build release APK from /tmp (avoids macOS ._ files on external volumes).
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
BUILD_DIR="${BUILD_DIR:-/tmp/nova_heronix_build}"
RELEASE_DIR="$ROOT/release/android"
export COPYFILE_DISABLE=1
export GRADLE_USER_HOME="${GRADLE_USER_HOME:-$HOME/.gradle}"

echo "==> Cleaning AppleDouble (._*) on project"
find "$ROOT" -name '._*' -delete 2>/dev/null || true

echo "==> Syncing to $BUILD_DIR"
rm -rf "$BUILD_DIR"
mkdir -p "$RELEASE_DIR"
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
echo "==> Building release APK"
flutter build apk --release

cp build/app/outputs/flutter-apk/app-release.apk "$RELEASE_DIR/"
echo ""
ls -lh "$RELEASE_DIR/app-release.apk"
echo "Done: $RELEASE_DIR/app-release.apk"
