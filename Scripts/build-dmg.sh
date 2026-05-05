#!/usr/bin/env bash
#
# Wrap the built .app into a styled drag-to-Applications DMG.
#
# Usage:
#   ./Scripts/build-dmg.sh                   # uses default version 0.1.0
#   ./Scripts/build-dmg.sh --version 0.2.0   # explicit version
#
# Requires: create-dmg (brew install create-dmg) and the .app bundle from
# Scripts/build-app.sh in dist/.

set -euo pipefail

VERSION="${VERSION:-0.1.0}"
APP_NAME="Menubar Prompter"
DMG_BASENAME="MenubarPrompter"

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
DMG="$DIST/$DMG_BASENAME-$VERSION.dmg"

if [[ ! -d "$APP" ]]; then
  echo "ERROR: $APP not found. Run Scripts/build-app.sh first." >&2
  exit 1
fi

if ! command -v create-dmg >/dev/null 2>&1; then
  echo "ERROR: create-dmg is not installed. Run: brew install create-dmg" >&2
  exit 1
fi

rm -f "$DMG"

# Stage a directory with a single .app so create-dmg only adds the app icon
# and the Applications symlink (no stray files).
STAGING="$DIST/dmg-staging"
rm -rf "$STAGING"
mkdir -p "$STAGING"
cp -R "$APP" "$STAGING/"

echo "==> Building DMG"
create-dmg \
  --volname "$APP_NAME" \
  --window-pos 200 120 \
  --window-size 540 360 \
  --icon-size 112 \
  --icon "$APP_NAME.app" 130 170 \
  --hide-extension "$APP_NAME.app" \
  --app-drop-link 410 170 \
  --no-internet-enable \
  "$DMG" \
  "$STAGING"

rm -rf "$STAGING"

echo ""
echo "Built: $DMG"
echo "Version: $VERSION"
