import AppKit
import SwiftUI

/// Owns the single reusable settings window.
final class SettingsWindowController {
  private lazy var window: NSWindow = {
    let hostingController = NSHostingController(
      rootView: SettingsView()
    )

    let window = NSWindow(
      contentRect: NSRect(x: 0, y: 0, width: 440, height: 140),
      styleMask: [.titled, .closable, .miniaturizable, .resizable],
      backing: .buffered,
      defer: false
    )
    window.title = L10n.string(.optionsTitle, language: AppPreferences.shared.language)
    window.contentViewController = hostingController
    window.contentMinSize = NSSize(width: 400, height: 110)
    window.isReleasedWhenClosed = false
    return window
  }()

  func show() {
    LoginItemService.shared.refresh()
    // SwiftUI must finish sizing the content before the entire window is centered.
    window.contentView?.layoutSubtreeIfNeeded()
    let snapshot = ScreenSnapshotProvider.capture()
    if let screen = ScreenResolver.screen(
      containing: NSEvent.mouseLocation,
      from: snapshot.screens
    ) {
      // NSWindow.center() uses optical centering. Use the exact visible-area
      // midpoint instead, including each time the options window is reopened.
      window.setFrameOrigin(
        LayoutEngine.anchoredOrigin(
          for: .centered,
          targetFrame: screen.visibleFrame,
          actualSize: window.frame.size
        )
      )
    }
    window.makeKeyAndOrderFront(nil)
    NSApp.activate(ignoringOtherApps: true)
  }
}
