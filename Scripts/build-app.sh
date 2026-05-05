#!/usr/bin/env bash
#
# Build Menubar Prompter into a distributable .app bundle.
#
# Usage:
#   ./Scripts/build-app.sh                  # builds with default version 0.1.0
#   ./Scripts/build-app.sh --version 0.2.0  # explicit version
#
# Output: dist/Menubar Prompter.app
#
# Requires: Xcode command line tools (swift, codesign, iconutil, sips).
# Produces a universal binary (arm64 + x86_64), ad-hoc signed.

set -euo pipefail

VERSION="${VERSION:-0.1.0}"
APP_NAME="Menubar Prompter"
EXECUTABLE_NAME="MenubarPrompter"
BUNDLE_ID="com.pallaoro.MenubarPrompter"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --version)
      VERSION="$2"
      shift 2
      ;;
    *)
      echo "Unknown flag: $1" >&2
      exit 1
      ;;
  esac
done

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
DIST="$ROOT/dist"
APP="$DIST/$APP_NAME.app"
ICON_SOURCE="$ROOT/Resources/AppIcon.png"

if [[ ! -f "$ICON_SOURCE" ]]; then
  echo "ERROR: $ICON_SOURCE not found" >&2
  exit 1
fi

rm -rf "$DIST"
mkdir -p "$APP/Contents/MacOS" "$APP/Contents/Resources"

echo "==> Building universal release binary (arm64 + x86_64)"
cd "$ROOT"
swift build -c release \
  --arch arm64 \
  --arch x86_64 \
  --disable-sandbox

BINARY="$ROOT/.build/apple/Products/Release/$EXECUTABLE_NAME"
if [[ ! -f "$BINARY" ]]; then
  echo "ERROR: built binary not found at $BINARY" >&2
  exit 1
fi
cp "$BINARY" "$APP/Contents/MacOS/$EXECUTABLE_NAME"

echo "==> Generating AppIcon.icns from Resources/AppIcon.png"
ICONSET="$DIST/AppIcon.iconset"
mkdir -p "$ICONSET"
for spec in "16:1" "16:2" "32:1" "32:2" "128:1" "128:2" "256:1" "256:2" "512:1" "512:2"; do
  size="${spec%:*}"
  scale="${spec#*:}"
  px=$((size * scale))
  if [[ "$scale" == "1" ]]; then
    out="$ICONSET/icon_${size}x${size}.png"
  else
    out="$ICONSET/icon_${size}x${size}@2x.png"
  fi
  sips -z "$px" "$px" "$ICON_SOURCE" --out "$out" >/dev/null
done
iconutil -c icns "$ICONSET" -o "$APP/Contents/Resources/AppIcon.icns"
rm -rf "$ICONSET"

echo "==> Writing Info.plist"
cat > "$APP/Contents/Info.plist" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>CFBundleExecutable</key>
  <string>$EXECUTABLE_NAME</string>
  <key>CFBundleIdentifier</key>
  <string>$BUNDLE_ID</string>
  <key>CFBundleName</key>
  <string>$APP_NAME</string>
  <key>CFBundleDisplayName</key>
  <string>$APP_NAME</string>
  <key>CFBundlePackageType</key>
  <string>APPL</string>
  <key>CFBundleShortVersionString</key>
  <string>$VERSION</string>
  <key>CFBundleVersion</key>
  <string>$VERSION</string>
  <key>CFBundleIconFile</key>
  <string>AppIcon</string>
  <key>LSMinimumSystemVersion</key>
  <string>14.0</string>
  <key>NSHighResolutionCapable</key>
  <true/>
  <key>NSPrincipalClass</key>
  <string>NSApplication</string>
</dict>
</plist>
PLIST

echo "==> Ad-hoc signing the bundle"
codesign --force --deep --sign - "$APP"

echo ""
echo "Built: $APP"
echo "Version: $VERSION"
