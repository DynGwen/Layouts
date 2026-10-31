# Changelog

## Unreleased — Transparent card backgrounds, original motifs

- Use clear Liquid Glass only for the backgrounds of the four floating layout cards. Keep the menu background and window controllers unchanged.
- Restore the original motif drawing code exactly, including opaque light-gray fills (#CCCCCC), outlines, captions, geometry and accent-colored hover.
- Use regular card backgrounds for Increase Contrast and opaque card backgrounds for Reduce Transparency. Refresh the card material when either setting changes.

Native compilation and visual QA remain pending on a Mac.

## 1.1.4 — Menu bar toggle and light-gray previews

- Let the status-button action alone toggle the panel: the first click opens it and the next closes it. Key-focus changes during status-button tracking no longer dismiss it before the action runs.
- Exclude clicks inside the status button's screen bounds from both outside-click monitors. Handle monitored events synchronously to avoid delayed dismissal of a newly opened panel.
- Keep dismissal on outside clicks, Escape, and activation of another application.
- Supply separate FR and EN source archives with fixed edition metadata.
- Draw the four layout diagrams and their screen outlines in opaque light gray (#CCCCCC) in both appearances.
- Disable vibrancy for preview content so materials do not alter the requested gray. Retain accent-colored hover feedback, adaptive captions, and stronger borders for Increase Contrast.

Native compilation and visual QA remain pending on a Mac.

## 1.1.3 — EvniaControl sliders and fixed-language editions

- Reuse EvniaControl's TahoePillSlider component for the two menu controls, adding only a macOS 26 availability guard for its glass thumb.
- Reduce Options to exactly two checkboxes: menu bar icon visibility and launch at login. Keep the options window compact and centered on each opening.
- Remove the language picker, persisted language preference and system-language mode. Each FR/EN edition reads its immutable language from bundle metadata; old saved choices have no effect.
- Copy only the edition's translation into the command-line-built application. Retain both tables in the shared source tree for validation.
- Keep margin and centered-size controls in the compact menu, permission help in the menu, existing window-management behavior and direct compilation without requiring full Xcode.

Native compilation and visual QA remain pending on a Mac.

## 1.1.2 — Command Line Tools build

- Remove the full-Xcode / `xcodebuild` prerequisite from the shell build. Resolve the selected `swiftc` and macOS SDK with `xcrun` and compile the app directly.
- Retain the shared observable permission state introduced in 1.1.1, avoiding the State macro that failed in 1.1.0.
- Keep staged compilation, resource copying, executable checks, signing verification and preservation of an existing app on failure.
- Require Swift 6.4 and the macOS 27 SDK or later, supplied by the selected development tools. The Xcode project remains an optional build route.

The previous error was the script’s full-Xcode check. The corrected script does not call `xcodebuild`. Native compilation is still unverified in the Linux preparation environment.

## 1.1.1 — Xcode 27 build correction

- Replace the settings view's `@State` permission flag with a shared `ObservableObject` using `@Published`. The settings and compact menu now observe the same authorization status without expanding a State macro.
- Build the shared Xcode project with `xcodebuild` so Xcode configures the SDK's Swift compiler plug-ins, rather than invoking `swiftc` directly for the application.
- Build and sign in a temporary staging directory, verify the executable and signature, then publish `build/Layouts.app`. Failed compilation or signing leaves an existing app unchanged.
- Keep the French and English variants, Liquid Glass appearance, centered options, and menu layout from 1.1.0.

The reported `SwiftUIMacros.StateMacro` / immutable-self failure occurred with 1.1.0 on a Mac. The 1.1.1 source removes that macro use and corrects the build route. Native compilation of 1.1.1 still requires confirmation on a Mac; local regression checks use simulated Xcode tools.

## 1.1.0 — macOS 27 and Liquid Glass

- Use `NSGlassEffectView` for the four floating layout targets on macOS 26 and later, including macOS 27.
- Group the glass views in `NSGlassEffectContainerView` for consistent sampling and efficient rendering; keep each target separate.
- Embed previews through the native glass `contentView`, so the system can apply its legibility treatments.
- Use a native visual-effect material on macOS 13–15 and opaque semantic backgrounds when Reduce Transparency is enabled.
- Adopt semantic colors for light/dark appearance, stronger borders for Increase Contrast, and immediate overlay presentation for Reduce Motion.
- Add target captions and refresh the Centered preview when its percentage changes.
- Keep overlay input transparent and non-activating. The macOS 27 interactive click effect stays disabled because the overlay must not receive clicks during another app's drag.
- Use a resizable grouped settings form with native glass permission buttons on macOS 26 and later.
- Replace the two-item status menu with an EvniaControl-style compact glass panel: status header, live margin and centered-size sliders, permission help, and Options/Quit footer.
- Close the panel on an outside click, a second status-button click, or Escape; keep it anchored within the current display.
- Localize the menu, options, layout captions, and accessibility labels in French and English. The language picker applies changes immediately; FR and EN source archives provide the corresponding first-launch default.
- Center the options window geometrically on the pointer's display every time it opens, including after moving or resizing the window. Placement uses the usable screen area, excluding the menu bar and Dock.
- Recompute overlay placement after changes to usable screen bounds, and fit smaller display areas.
- Require Xcode 27 / macOS 27 SDK for application builds while retaining a macOS 13 deployment target, existing preferences, and the bundle identifier.
- Add a shared Xcode scheme, complete localization tables for both build paths, and smoke tests for overlay layout, settings centering, menu placement, and localization.

Validation in the supplied environment is limited to static checks: no macOS SDK or Swift compiler is installed. The application build, Swift smoke tests, and on-device visual checks remain to be run on a Mac. See `VALIDATION.md`.
