import AppKit
import Foundation

/// Coordinates application services and owns the long-lived controllers.
final class AppDelegate: NSObject, NSApplicationDelegate {
  private let preferences = AppPreferences.shared
  private let applicationTracker = FrontmostApplicationTracker()
  private let settingsWindowController = SettingsWindowController()
  private let overlayController = OverlayWindowController()

  private var windowEngine: WindowEngine!
  private var windowDragMonitor: WindowDragMonitor!
  private var menuBarController: MenuBarController!

  func applicationDidFinishLaunching(_ notification: Notification) {
    NSApp.setActivationPolicy(.accessory)
    applicationTracker.start()

    windowEngine = WindowEngine(
      preferences: preferences
    ) { [weak self] in
      DispatchQueue.main.async {
        _ = AccessibilityService.requestAccess(prompt: true)
        self?.settingsWindowController.show()
      }
    }

    windowDragMonitor = WindowDragMonitor(
      overlayController: overlayController,
      windowEngine: windowEngine,
      applicationTracker: applicationTracker
    )
    windowDragMonitor.start()

    menuBarController = MenuBarController(
      preferences: preferences,
      onSettings: { [weak self] in
        self?.settingsWindowController.show()
      }
    )

    if !AccessibilityService.isTrusted {
      _ = AccessibilityService.requestAccess(prompt: true)
      settingsWindowController.show()
    }
  }

  func applicationShouldHandleReopen(
    _ sender: NSApplication,
    hasVisibleWindows flag: Bool
  ) -> Bool {
    settingsWindowController.show()
    return false
  }

  func applicationWillTerminate(_ notification: Notification) {
    windowDragMonitor?.stop()
    applicationTracker.stop()
  }
}
