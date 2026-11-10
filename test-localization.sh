#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")" && pwd)"
TEST_DIR="$(mktemp -d "${TMPDIR:-/tmp}/layouts-localization.XXXXXX")"
trap 'rm -rf "$TEST_DIR"' EXIT

swiftc -swift-version 5 \
  "$ROOT_DIR/Sources/Models/AppLanguage.swift" \
  "$ROOT_DIR/Sources/Models/L10n.swift" \
  "$ROOT_DIR/Tests/LocalizationSmokeTests.swift" \
  -o "$TEST_DIR/layouts-localization-tests"

# Build a bundle with the same structure as the installed macOS app.
# Bundle(path:) does not load Info.plist from a bare Resources directory.
TEST_BUNDLE="$TEST_DIR/LayoutsLocalization.bundle"
mkdir -p "$TEST_BUNDLE/Contents/Resources"
cp "$ROOT_DIR/Resources/Info.plist" "$TEST_BUNDLE/Contents/Info.plist"
cp -R "$ROOT_DIR/Resources/en.lproj" "$TEST_BUNDLE/Contents/Resources/"
cp -R "$ROOT_DIR/Resources/fr.lproj" "$TEST_BUNDLE/Contents/Resources/"

"$TEST_DIR/layouts-localization-tests" "$TEST_BUNDLE"
