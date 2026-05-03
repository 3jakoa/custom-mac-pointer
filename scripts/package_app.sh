#!/bin/sh
set -eu

ROOT_DIR="$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)"
BUILD_CONFIG="${1:-debug}"
APP_DIR="$ROOT_DIR/build/Burek Mac Pointer.app"
CONTENTS_DIR="$APP_DIR/Contents"
MACOS_DIR="$CONTENTS_DIR/MacOS"
RESOURCES_DIR="$CONTENTS_DIR/Resources"

cd "$ROOT_DIR"
swift build -c "$BUILD_CONFIG"

rm -rf "$APP_DIR"
mkdir -p "$MACOS_DIR" "$RESOURCES_DIR"
cp ".build/$BUILD_CONFIG/CustomMacPointer" "$MACOS_DIR/CustomMacPointer"
cp "Resources/Info.plist" "$CONTENTS_DIR/Info.plist"
if [ -d "$ROOT_DIR/Sources/CustomMacPointer/Resources/Bureks" ]; then
    cp -R "$ROOT_DIR/Sources/CustomMacPointer/Resources/Bureks" "$RESOURCES_DIR/Bureks"
fi
if [ -d "$ROOT_DIR/Sources/CustomMacPointer/Resources/Boreks" ]; then
    cp -R "$ROOT_DIR/Sources/CustomMacPointer/Resources/Boreks" "$RESOURCES_DIR/Boreks"
fi

xattr -cr "$APP_DIR" >/dev/null 2>&1 || true
codesign --force --sign - "$APP_DIR" >/dev/null 2>&1 || true

printf '%s\n' "$APP_DIR"
