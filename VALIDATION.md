# Validation — Layouts 1.1.4 — English edition

This source archive builds the English edition. `LayoutsLanguage`, `CFBundleDevelopmentRegion`, and `CFBundleLocalizations` are set to `en`; the Xcode development region is also `en`. The edition determines the interface language, regardless of macOS language or a language preference saved by an older release.

## Checks performed

- The 20 English translation keys match the declared localization keys and the French table. Both tables remain available in the source project for the localization smoke tests. The shell build packages only the English table.
- All Swift application sources, tests, and build scripts are identical to the latest French edition. Edition-specific changes are limited to bundle metadata, the Xcode development region, and documentation.
- The English table covers the menu, sliders, options, accessibility names, and permission help. Target names remain available to VoiceOver without appearing on the diagrams.
- Shell script syntax, archive integrity, original file structure, and file permissions are checked.

This preparation environment runs Linux without Swift, Xcode, or a macOS SDK. Native compilation, Swift smoke tests, and visual checks have not been performed. No compiled macOS application is included.

## Appearance preserved

The four target diagrams retain a fixed 16:10 screen aspect ratio, centered inside cards of the approved size. Full Screen, Left, Right, and Centered captions remain hidden. The targets retain clear glass, light-gray diagrams, and accent-colored hover feedback.

The menu panel uses EvniaControl 1.0.35's regular Liquid Glass surface, 16-point continuous corners, SwiftUI clipping, and window-frame clipping. Reduce Transparency uses an opaque background. macOS 13–15 retain fallback materials.

## Run on a Mac

```bash
./test-geometry.sh
./test-localization.sh
./build.sh && open build/Layouts.app
```

The build requires Swift 6.4 or later and the macOS 27 SDK or later, available through `xcrun`. See [README.md](README.md) for build instructions.

## Manual checks pending

- On a Mac configured in French, confirm that the menu, options, permission help, and VoiceOver target names are in English. Repeat with an older saved language preference.
- Compare the menu panel with EvniaControl above the same background, with the same system appearance. Check the glass and rounded corners in light and dark modes.
- Open and close the menu using the status icon, an outside click, Escape, and application switching. Check placement near screen edges and when permission help appears.
- Adjust both sliders and verify their displayed values and corresponding layout behavior.
- Drag a window onto each target. Check the 16:10 diagrams, hover feedback, and final window positions on multiple displays.
- Check Increase Contrast, Reduce Transparency, Reduce Motion, launch at login, and hiding and restoring the menu bar icon.

Earlier changes and validation limitations are recorded in [CHANGELOG.md](CHANGELOG.md).
