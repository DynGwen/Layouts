# Layouts

**Arrange Mac windows quickly using drag-and-drop layout targets.**

Layouts is a lightweight macOS menu-bar utility that lets you position and resize windows without manually adjusting their edges. Drag a window toward one of four floating layout targets and release it to apply the chosen arrangement. The application runs quietly in the menu bar and uses the macOS Accessibility API to manage windows.

## Features

- **Four window layouts:** Fill the usable screen area, occupy its left or right half, or center a window at a configurable size.
- **Drag-and-drop controls:** Floating targets appear while you move a window; release over a target to apply that layout.
- **Adjustable window margin:** Choose a margin of **0–40 pt** (default **12 pt**) from the menu-bar panel.
- **Adjustable centered size:** Set the centered layout to **30–100%** of the usable area (default **60%**, in 5% steps).
- **Live layout previews:** The target diagrams reflect your centered-size setting.
- **Multiple displays:** Targets follow the display containing the pointer, and layouts respect the available desktop area, including the Dock and menu bar.
- **Accessible interface:** Layout targets have VoiceOver names. Increase Contrast, Reduce Transparency, and Reduce Motion are respected where applicable.
- **Readable controls:** Slider handles stay **solid white** in light and dark appearance. The `pt` and `%` values are drawn at full text opacity.
- **Menu-bar preferences:** Show or hide the menu-bar icon and optionally launch Layouts at login.
- **French and English editions:** Each download has a fixed interface language, independently of the language selected in macOS.

## Requirements

- **macOS 13 or later** to run the application.
- A **Mac with Apple Silicon or Intel** hardware.
- **Apple developer tools** with **Swift 6.4 or later** and the **macOS 27 SDK or later** for the included source-based installer. The SDK requirement applies to building, not to the minimum runtime version.
- **Accessibility permission** to detect and arrange application windows.

> **This package contains the source code and an installation script, not a precompiled application.** The application is built locally on your Mac. No third-party packages or network services are required by Layouts itself.

## Installation

1. Extract the **English (EN)** or **French (FR)** Layouts archive to a folder where you have write access.
2. Double-click **`install.command`** in the extracted folder. macOS may ask you to confirm that you want to open the script.
3. The installer checks the development tools, runs source tests, builds and signs `Layouts.app`, and installs it in **`/Applications`**. Approve the administrator prompt if requested.
4. Layouts launches automatically. Look for its window-layout icon in the macOS menu bar.
5. When prompted, open **System Settings → Privacy & Security → Accessibility** and allow **Layouts**. Restart the app if the permission does not become active immediately.

To launch the installer from Terminal instead:

```bash
cd /path/to/extracted/Layouts-EN  # or Layouts-FR
chmod +x install.command build.sh test-geometry.sh test-localization.sh
./install.command
```

If the developer tools are missing, install or update Xcode or Apple's Command Line Tools, select a toolchain that includes the required SDK, then run the installer again. If installation is blocked by macOS security controls, review the prompt in System Settings rather than disabling system security features.

**Only one edition can be installed at a time.** Both editions use the same application name and bundle identifier. To change the interface language, install the other edition; your saved settings are retained.

## Using Layouts

1. Click the **Layouts** icon in the menu bar to open its compact control panel.
2. Set **Window Margin** (`pt`) and **Centered Layout Size** (`%`) to your preferred values.
3. Drag a window by its title bar. Floating layout targets appear.
4. Move the pointer over the desired target and release the window.
5. Click the menu-bar icon again, click outside the panel, or press **Esc** to dismiss the panel. Layouts continues to run.

### Layout targets

| Target | Result |
| --- | --- |
| **Full Screen** | Fills the usable screen area, leaving the chosen margin. This does **not** create a separate macOS full-screen Space. |
| **Left** | Positions the window in the left half of the usable area. |
| **Right** | Positions the window in the right half of the usable area. |
| **Centered** | Centers the window at the selected percentage of the usable width and height. |

Some applications enforce minimum window dimensions or do not expose resizable windows through Accessibility. Layouts adjusts the placement when possible, but the application can limit the final result.

## Options

Open **Options…** from the menu-bar panel to manage:

- **Show menu bar icon** — Show or hide the Layouts icon in the menu bar. If hidden, open `Layouts.app` again to display Options.
- **Launch Layouts at login** — Start the application when you sign in to macOS.

Choose **Quit** from the panel to stop Layouts.

## Privacy and permissions

Layouts needs **Accessibility** access so it can follow a window being dragged and update its position and dimensions. Enable access in **System Settings → Privacy & Security → Accessibility**. **Screen Recording is not required.** Layouts does not require an online account or send window information to a remote service.

## Troubleshooting

| Issue | Suggested action |
| --- | --- |
| Layout targets do not appear | Check the Accessibility permission and restart Layouts if necessary. Begin dragging a normal resizable window by its title bar. |
| A window does not resize as expected | The application may enforce minimum dimensions or restrict Accessibility window changes. Try another window. |
| Menu-bar icon is missing | Open `Layouts.app` to show Options and enable **Show menu bar icon**. |
| Launch at login cannot be enabled | Check **System Settings → General → Login Items & Extensions** and review any message in Options. |
| The installer fails | Confirm macOS developer tools are installed and `xcrun --sdk macosx --show-sdk-version` reports version 27 or later. |
| macOS asks for Accessibility access again | Allow the installed copy in `/Applications`, then quit and reopen Layouts. |

## Build from source

The package also includes an Xcode project and a direct build script. From the extracted edition folder, run:

```bash
./test-geometry.sh
./test-localization.sh
./build.sh
open build/Layouts.app
```

The build script produces a locally signed app for the Mac's current architecture in `build/Layouts.app`. Its language is fixed by the edition's `Resources/Info.plist`; the build copies only that edition's localization into the resulting app.

## Compatibility note

On macOS 26 or later, floating targets and the menu use native Liquid Glass where supported. Earlier macOS versions use fallback materials. The target surfaces may be translucent by design, but the **slider thumbs are opaque white** and the **numeric settings labels are fully opaque**. Exact appearance and window-management behavior should be verified on your Mac.
