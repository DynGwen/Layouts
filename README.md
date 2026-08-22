# Layouts 1.0.5

Layouts is a small native macOS application designed for visual window management through drag and drop.

When a window is moved, four translucent white targets automatically appear on the right side of the screen. Release the window over the desired target to apply the corresponding layout.

## How it works

```text
Move a window
      │
      ▼
Layouts detects the movement
      │
      ▼
4 targets appear on the right
      │
      ├── Full Screen
      ├── Left
      ├── Right
      └── Centered (adjustable percentage)
      │
      ▼
Hover target → highlight
      │
      ▼
Release → apply layout
```

The overlay is transparent, non-activating, and lets mouse events pass through. It does not take focus or interrupt the window drag.

## Layouts

| Target | Geometry |
| --- | --- |
| Full Screen | Entire usable screen area, minus the configured margin |
| Left | Left half of the usable screen height |
| Right | Right half of the usable screen height |
| Centered | Adjustable percentage of the full-screen width and height, centered horizontally and vertically |

The Centered layout uses the percentage configured in Settings for both width and height. The default is `60% × 60%`. Its horizontal and vertical centers exactly match the center of the usable screen area.

The usable area is based on `NSScreen.visibleFrame`, so the menu bar and Dock are automatically respected.

## Version 1.0.5

Version 1.0.5 provides a fully English user interface while keeping the same behavior as version 1.0.4.

The Centered layout size remains adjustable from `30%` to `100%` in `5%` increments, with `60%` as the default. The same percentage is applied to width and height, and centering is recalculated after any size constraints imposed by the target application.

## Settings

The application interface is entirely in English:

- window margin: `0 to 40 pt`;
- centered layout size: `30 to 100%`, in `5%` increments;
- show or hide the menu bar icon;
- launch Layouts at login;
- check Accessibility permission.

When the menu bar icon is hidden, Layouts continues to run in the background. Launching `Layouts.app` again from Applications simply reopens the Settings window.

## No keyboard shortcuts

Layouts 1.0.5 does not include a keyboard shortcut manager. The former Carbon hotkey code is not part of the project.

Usage relies only on:

1. dragging a window onto one of the visual targets;
2. the menu bar menu to open Settings or quit the application.

## App icon

A dedicated macOS icon is included in `Resources/AppIcon.icns` and bundled with the application.

## Multiple displays

The overlay follows the display containing the mouse pointer. If a window is moved from one display to another and dropped onto a target, the geometry is calculated from the destination display.

## Persisted data

Only these preferences are persisted:

- margin width;
- centered layout percentage;
- menu bar icon visibility;
- launch-at-login state, managed by macOS.

No window position is saved to disk.

## Requirements

- macOS 13 or later;
- Accessibility permission;
- Xcode or Xcode Command Line Tools to build from source.

Screen Recording permission is not required.

## Build

From Terminal on macOS:

```bash
cd Layouts-1.0.5
./build.sh
open build/Layouts.app
```

The build script uses ad hoc signing by default. To make Accessibility permission more stable across rebuilds, you can use a persistent Apple Development identity:

```bash
CODE_SIGN_IDENTITY="Apple Development: Your Name (...)" ./build.sh
```

You can also open `Layouts.xcodeproj` directly in Xcode.

## First launch

Layouts requests Accessibility permission. If needed, open:

**System Settings → Privacy & Security → Accessibility**

## Architecture

```text
Global mouse events
        │
        ▼
WindowDragMonitor ───────────────┐
        │                        │
        ▼                        ▼
OverlayWindowController      WindowEngine
        │                   /      |       \
        ▼                  /       |        \
LayoutOverlayView      AX client  ScreenResolver  LayoutEngine
        │                                        │
        └── hovered target                        └── CGRect
```

Source code, type names, method names, and comments are in English. All user-visible strings are also in English in version 1.0.5.

## Current scope

Layouts 1.0.5 intentionally does not include:

- keyboard shortcuts;
- saving or restoring window positions;
- custom layouts;
- a radial menu;
- telemetry or network access;
- third-party dependencies.

Some applications enforce minimum window sizes. Layouts requests the target geometry from macOS, but the target application may still apply its own constraints.
