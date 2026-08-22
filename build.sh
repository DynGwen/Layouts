#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")" && pwd)"
APP_NAME="Layouts"
BUILD_DIR="$ROOT_DIR/build"
APP_BUNDLE="$BUILD_DIR/$APP_NAME.app"
CONTENTS_DIR="$APP_BUNDLE/Contents"
MACOS_DIR="$CONTENTS_DIR/MacOS"
RESOURCES_DIR="$CONTENTS_DIR/Resources"

if [[ "$(uname -s)" != "Darwin" ]]; then
    echo "Layouts must be built on macOS."
    exit 1
fi

ARCH="$(uname -m)"
case "$ARCH" in
    arm64|x86_64) ;;
    *)
        echo "Unsupported architecture: $ARCH"
        exit 1
        ;;
esac

SDK_PATH="$(xcrun --sdk macosx --show-sdk-path)"
TARGET="$ARCH-apple-macos13.0"

rm -rf "$APP_BUNDLE"
mkdir -p "$MACOS_DIR" "$RESOURCES_DIR"
cp "$ROOT_DIR/Resources/Info.plist" "$CONTENTS_DIR/Info.plist"
cp "$ROOT_DIR/Resources/AppIcon.icns" "$RESOURCES_DIR/AppIcon.icns"

SOURCES=()
while IFS= read -r line; do
    SOURCES+=("$line")
done < <(find "$ROOT_DIR/Sources" -name '*.swift' -print | sort)

xcrun swiftc \
    -swift-version 5 \
    -O \
    -parse-as-library \
    -target "$TARGET" \
    -sdk "$SDK_PATH" \
    "${SOURCES[@]}" \
    -framework AppKit \
    -framework ApplicationServices \
    -framework Combine \
    -framework ServiceManagement \
    -framework SwiftUI \
    -o "$MACOS_DIR/$APP_NAME"

SIGN_IDENTITY="${CODE_SIGN_IDENTITY:--}"
codesign --force --deep --sign "$SIGN_IDENTITY" "$APP_BUNDLE"

echo "Built: $APP_BUNDLE"
echo "Run:   open \"$APP_BUNDLE\""
