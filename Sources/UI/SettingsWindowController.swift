import AppKit
import SwiftUI

/// Owns the single reusable settings window.
final class SettingsWindowController {
  private lazy var window: NSWindow = {
    let hostingController = NSHostingController(
      rootView: SettingsView()
    )

    let window = NSWindow(
      contentRect: NSRect(x: 0, y: 0, width: 470, height: 570),
      styleMask: [.titled, .closable, .miniaturizable],
      backing: .buffered,
      defer: false
    )
    window.title = "Layouts Settings"
    window.contentViewController = hostingController
    window.isReleasedWhenClosed = false
    window.center()
    return window
  }()

  func show() {
    window.makeKeyAndOrderFront(nil)
    NSApp.activate(ignoringOtherApps: true)
  }
}
