#!/bin/sh
set -eu

ROOT_DIR="$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)"
BUILD_CONFIG="${1:-debug}"
APP_DIR="$ROOT_DIR/build/Custom Mac Pointer.app"
CONTENTS_DIR="$APP_DIR/Contents"
MACOS_DIR="$CONTENTS_DIR/MacOS"

cd "$ROOT_DIR"
swift build -c "$BUILD_CONFIG"

rm -rf "$APP_DIR"
mkdir -p "$MACOS_DIR"
cp ".build/$BUILD_CONFIG/CustomMacPointer" "$MACOS_DIR/CustomMacPointer"
cp "Resources/Info.plist" "$CONTENTS_DIR/Info.plist"

codesign --force --deep --sign - "$APP_DIR" >/dev/null 2>&1 || true

printf '%s\n' "$APP_DIR"
