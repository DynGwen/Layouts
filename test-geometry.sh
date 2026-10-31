#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")" && pwd)"
TEST_DIR="$(mktemp -d "${TMPDIR:-/tmp}/layouts-geometry.XXXXXX")"
trap 'rm -rf "$TEST_DIR"' EXIT
OUTPUT="$TEST_DIR/layouts-geometry-tests"

swiftc \
  -swift-version 5 \
  "$ROOT_DIR/Sources/Models/AppLanguage.swift" \
  "$ROOT_DIR/Sources/Models/L10n.swift" \
  "$ROOT_DIR/Sources/Models/LayoutAction.swift" \
  "$ROOT_DIR/Sources/Core/ScreenGeometry.swift" \
  "$ROOT_DIR/Sources/Core/LayoutEngine.swift" \
  "$ROOT_DIR/Sources/Core/CoordinateConverter.swift" \
  "$ROOT_DIR/Sources/Core/ScreenResolver.swift" \
  "$ROOT_DIR/Sources/Overlay/LayoutDropZone.swift" \
  "$ROOT_DIR/Sources/Overlay/LayoutOverlayGeometry.swift" \
  "$ROOT_DIR/Sources/UI/MenuPanelGeometry.swift" \
  "$ROOT_DIR/Tests/GeometrySmokeTests.swift" \
  -o "$OUTPUT"

"$OUTPUT"
