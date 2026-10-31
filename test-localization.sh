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

"$TEST_DIR/layouts-localization-tests" "$ROOT_DIR/Resources"
