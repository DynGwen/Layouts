#!/bin/bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")" && pwd)"
APP_NAME="Layouts"
BUILT_APP="$ROOT_DIR/build/$APP_NAME.app"
INSTALL_APP="/Applications/$APP_NAME.app"

log() { printf '[Layouts] %s\n' "$1"; }
fail() { printf '[Layouts] Error: %s\n' "$1" >&2; exit 1; }

if [[ "$(uname -s)" != "Darwin" ]]; then
  fail "Run this installer on a Mac."
fi

if ! command -v xcrun >/dev/null 2>&1 || ! xcode-select -p >/dev/null 2>&1; then
  log "Apple developer tools are required."
  xcode-select --install || true
  fail "Finish installing developer tools, then run install.command again."
fi

log "Checking the Layouts source and translations..."
"$ROOT_DIR/test-geometry.sh"
"$ROOT_DIR/test-localization.sh"

log "Compiling and signing Layouts..."
"$ROOT_DIR/build.sh"
[[ -d "$BUILT_APP" && -x "$BUILT_APP/Contents/MacOS/Layouts" ]] || fail "The app could not be built."

log "Installing Layouts in /Applications..."
# Quit only the running Layouts executable; user preferences are not removed.
pkill -x "$APP_NAME" >/dev/null 2>&1 || true

# Copy the completed app into /Applications. Keep the old app intact until
# copying succeeds; restore it if the final move unexpectedly fails.
/usr/bin/osascript - "$BUILT_APP" "$INSTALL_APP" <<'APPLESCRIPT'
on run argv
    set sourceApp to item 1 of argv
    set destinationApp to item 2 of argv
    set stagingApp to destinationApp & ".installing"
    set backupApp to destinationApp & ".backup"

    set shellCommand to "/bin/rm -rf " & quoted form of stagingApp & " && " & ¬
        "/usr/bin/ditto " & quoted form of sourceApp & " " & quoted form of stagingApp & " && " & ¬
        "/bin/rm -rf " & quoted form of backupApp & " && " & ¬
        "if test -e " & quoted form of destinationApp & "; then /bin/mv " & ¬
        quoted form of destinationApp & " " & quoted form of backupApp & "; fi && " & ¬
        "if /bin/mv " & quoted form of stagingApp & " " & quoted form of destinationApp & ¬
        "; then /bin/rm -rf " & quoted form of backupApp & "; else " & ¬
        "if test -e " & quoted form of backupApp & "; then /bin/mv " & ¬
        quoted form of backupApp & " " & quoted form of destinationApp & "; fi; exit 1; fi"

    do shell script shellCommand with administrator privileges
end run
APPLESCRIPT

log "Installed: $INSTALL_APP"
log "Launching Layouts..."
open "$INSTALL_APP"
log "Grant Accessibility permission in System Settings if prompted."
