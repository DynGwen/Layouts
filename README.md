# Layouts 1.1.4 — English edition

Layouts arranges Mac windows by drag and drop. Move a window over one of the four floating targets and release to apply the layout.

[Documentation française](README.fr.md) · [Changes](CHANGELOG.md) · [Validation](VALIDATION.md)

## Menu and sliders

The compact menu uses the same `TahoePillSlider` component as EvniaControl: a 6-point track and a rounded 20 × 16-point Liquid Glass thumb. The two controls adjust window margin (0–40 points) and centered size (30–100%, in 5% steps). Their values and layout previews update together. Defaults remain 12 points and 60%.

Click the menu bar icon to open the panel. A second click, an outside click, or Escape closes it. Options and Quit remain in the footer. Accessibility permission help appears in the menu when needed.

## Options

The compact options window contains exactly two settings:

- Show menu bar icon.
- Launch Layouts at login.

The window is geometrically centered in the usable area of the pointer's display each time it opens. If the menu bar icon is hidden, opening `Layouts.app` again opens Options. A login-service failure can display an explanatory message under the two settings.

## Separate French and English editions

The FR archive builds the French edition; the EN archive builds the English edition. The language is fixed by that edition, regardless of system language or language preferences saved by older releases. There is no language selector or language preference.

The shell build copies only the edition's localization into the app. Both translation tables remain in the shared source project for validation and development. Switching edition means building the other archive. Existing margin, size, icon and login preferences are retained.

## Window layouts

| Target | Result |
| --- | --- |
| Full Screen | Usable screen area minus the margin; does not enter a new macOS full-screen Space |
| Left | Left half of the usable area |
| Right | Right half of the usable area |
| Centered | Chosen percentage of width and height, centered on both axes |

The destination display follows the pointer. `NSScreen.visibleFrame` respects the menu bar and Dock. Apps can enforce their own minimum window sizes; Layouts then corrects the layout anchor.

## Liquid Glass and accessibility

On macOS 26 and later, including macOS 27, the floating targets and menu use native Liquid Glass effects. The slider component is reused from EvniaControl, with an availability guard for older systems. macOS 13–15 use fallback materials. Reduce Transparency, Increase Contrast and Reduce Motion are respected. The overlay passes drag input through without taking focus.

On first launch, allow Layouts in **System Settings → Privacy & Security → Accessibility**. Screen Recording permission is not required.

## Build on a Mac

Runtime requirement: macOS 13 or later. The shell build needs Swift 6.4 or later and the macOS 27 SDK or later, resolvable through `xcrun`. It does not call `xcodebuild` or require the full Xcode application.

From the extracted edition's source directory:

```bash
./test-geometry.sh
./test-localization.sh
./build.sh && open build/Layouts.app
```

If your extractor removes executable permissions, run `chmod +x *.sh` first. The script compiles for the current architecture, verifies the executable, signs the app, and publishes it only after success. A failed build preserves an existing app. Ad hoc signing is the default; `CODE_SIGN_IDENTITY` can select an Apple Development identity.

Xcode users can also open `Layouts.xcodeproj` and build the shared Layouts scheme. No third-party dependencies or network services are used by the application.

These are source archives. This preparation environment runs Linux without Swift or macOS SDKs; native compilation and visual behavior still require verification on a Mac. Static checks and simulated build checks are described in `VALIDATION.md`.
