#!/bin/sh
set -eu

ROOT_DIR="$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)"
BUILD_CONFIG="${1:-debug}"
APP_DIR="$ROOT_DIR/build/Burek Cursor.app"
CONTENTS_DIR="$APP_DIR/Contents"
MACOS_DIR="$CONTENTS_DIR/MacOS"
RESOURCES_DIR="$CONTENTS_DIR/Resources"
FRAMEWORKS_DIR="$CONTENTS_DIR/Frameworks"

cd "$ROOT_DIR"
swift build -c "$BUILD_CONFIG"

rm -rf "$APP_DIR"
mkdir -p "$MACOS_DIR" "$RESOURCES_DIR" "$FRAMEWORKS_DIR"
cp ".build/$BUILD_CONFIG/CustomMacPointer" "$MACOS_DIR/CustomMacPointer"
cp "Resources/Info.plist" "$CONTENTS_DIR/Info.plist"
cp "Resources/BurekCursor.icns" "$RESOURCES_DIR/BurekCursor.icns"
if [ -d ".build/$BUILD_CONFIG/Sparkle.framework" ]; then
    cp -R ".build/$BUILD_CONFIG/Sparkle.framework" "$FRAMEWORKS_DIR/Sparkle.framework"
fi
if [ -d "$ROOT_DIR/Sources/CustomMacPointer/Resources/Bureks" ]; then
    cp -R "$ROOT_DIR/Sources/CustomMacPointer/Resources/Bureks" "$RESOURCES_DIR/Bureks"
fi
if [ -d "$ROOT_DIR/Sources/CustomMacPointer/Resources/Boreks" ]; then
    cp -R "$ROOT_DIR/Sources/CustomMacPointer/Resources/Boreks" "$RESOURCES_DIR/Boreks"
fi

if [ -d "$FRAMEWORKS_DIR/Sparkle.framework" ]; then
    install_name_tool -add_rpath "@executable_path/../Frameworks" "$MACOS_DIR/CustomMacPointer" >/dev/null 2>&1 || true
fi

xattr -cr "$APP_DIR" >/dev/null 2>&1 || true
codesign --force --deep --sign - "$APP_DIR" >/dev/null 2>&1 || true

printf '%s\n' "$APP_DIR"
