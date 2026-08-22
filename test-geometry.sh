#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")" && pwd)"
OUTPUT="${TMPDIR:-/tmp}/layouts-geometry-tests"

swiftc \
  -swift-version 5 \
  "$ROOT_DIR/Sources/Models/LayoutAction.swift" \
  "$ROOT_DIR/Sources/Core/ScreenGeometry.swift" \
  "$ROOT_DIR/Sources/Core/LayoutEngine.swift" \
  "$ROOT_DIR/Sources/Core/CoordinateConverter.swift" \
  "$ROOT_DIR/Sources/Core/ScreenResolver.swift" \
  "$ROOT_DIR/Tests/GeometrySmokeTests.swift" \
  -o "$OUTPUT"

"$OUTPUT"
