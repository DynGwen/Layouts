#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")" && pwd)"
APP_NAME="Layouts"
BUILD_DIR="$ROOT_DIR/build"
APP_BUNDLE="$BUILD_DIR/$APP_NAME.app"

if [[ "$(uname -s)" != "Darwin" ]]; then
    echo "Layouts must be built on macOS."
    exit 1
fi

ARCH="$(uname -m)"
case "$ARCH" in
    arm64|x86_64) ;;
    *) echo "Unsupported architecture: $ARCH"; exit 1 ;;
esac

# Only the selected compiler and SDK are needed; do not require xcodebuild.
if ! SWIFT_COMPILER="$(xcrun --sdk macosx --find swiftc)"; then
    echo "Layouts requires the Swift compiler from Apple's macOS development tools."
    exit 1
fi
SDK_PATH="$(xcrun --sdk macosx --show-sdk-path)"
SDK_VERSION="$(xcrun --sdk macosx --show-sdk-version)"
SDK_MAJOR="${SDK_VERSION%%.*}"
if ! [[ "$SDK_MAJOR" =~ ^[0-9]+$ ]] || (( SDK_MAJOR < 27 )); then
    echo "Layouts requires the macOS 27 SDK or later."
    echo "Selected SDK: $SDK_VERSION. Update the Command Line Tools or select a newer toolchain."
    exit 1
fi

APP_LANGUAGE="$(/usr/libexec/PlistBuddy -c "Print :LayoutsLanguage" "$ROOT_DIR/Resources/Info.plist")"
case "$APP_LANGUAGE" in
    fr|en) ;;
    *) echo "Invalid application edition: Resources/Info.plist must declare fr or en."; exit 1 ;;
esac

mkdir -p "$BUILD_DIR"
STAGING_DIR="$(mktemp -d "$BUILD_DIR/.layouts-build.XXXXXX")"
trap 'rm -rf "$STAGING_DIR"' EXIT
STAGED_APP="$STAGING_DIR/$APP_NAME.app"
CONTENTS_DIR="$STAGED_APP/Contents"
MACOS_DIR="$CONTENTS_DIR/MacOS"
RESOURCES_DIR="$CONTENTS_DIR/Resources"
mkdir -p "$MACOS_DIR" "$RESOURCES_DIR"
cp "$ROOT_DIR/Resources/Info.plist" "$CONTENTS_DIR/Info.plist"
cp "$ROOT_DIR/Resources/AppIcon.icns" "$RESOURCES_DIR/AppIcon.icns"
cp -R "$ROOT_DIR/Resources/$APP_LANGUAGE.lproj" "$RESOURCES_DIR/"

/usr/libexec/PlistBuddy -c "Add :DTSDKName string macosx$SDK_VERSION" "$CONTENTS_DIR/Info.plist"

SOURCES=()
while IFS= read -r source; do
    SOURCES+=("$source")
done < <(find "$ROOT_DIR/Sources" -name '*.swift' -print | sort)

# Permission state uses ObservableObject; no State macro plug-in is required.
"$SWIFT_COMPILER" \
    -swift-version 5 \
    -O \
    -parse-as-library \
    -target "$ARCH-apple-macos13.0" \
    -sdk "$SDK_PATH" \
    "${SOURCES[@]}" \
    -framework AppKit \
    -framework ApplicationServices \
    -framework Combine \
    -framework ServiceManagement \
    -framework SwiftUI \
    -o "$MACOS_DIR/$APP_NAME"

if [[ ! -x "$MACOS_DIR/$APP_NAME" ]]; then
    echo "Build failed: the Layouts executable is missing or is not executable."
    exit 1
fi

SIGN_IDENTITY="${CODE_SIGN_IDENTITY:--}"
codesign --force --deep --sign "$SIGN_IDENTITY" "$STAGED_APP"
codesign --verify --deep --strict "$STAGED_APP"

# Publish only the complete, signed application.
rm -rf "$APP_BUNDLE"
mv "$STAGED_APP" "$APP_BUNDLE"

echo "Built: $APP_BUNDLE"
echo "Run:   open \"$APP_BUNDLE\""
