import AppKit
import Combine
import Foundation

/// Manages the optional menu bar item without taking application focus.
final class MenuBarController: NSObject {
  private let preferences: AppPreferences
  private let onSettings: () -> Void

  private var statusItem: NSStatusItem?
  private var cancellable: AnyCancellable?

  init(
    preferences: AppPreferences,
    onSettings: @escaping () -> Void
  ) {
    self.preferences = preferences
    self.onSettings = onSettings
    super.init()

    cancellable = preferences.$showMenuBarIcon
      .removeDuplicates()
      .receive(on: RunLoop.main)
      .sink { [weak self] visible in
        self?.setVisible(visible)
      }
  }

  private func setVisible(_ visible: Bool) {
    if visible {
      createStatusItemIfNeeded()
    } else if let statusItem {
      NSStatusBar.system.removeStatusItem(statusItem)
      self.statusItem = nil
    }
  }

  private func createStatusItemIfNeeded() {
    guard statusItem == nil else {
      return
    }

    let item = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
    if let button = item.button {
      if let image = NSImage(
        systemSymbolName: "rectangle.3.group",
        accessibilityDescription: "Layouts"
      ) {
        image.isTemplate = true
        button.image = image
      } else {
        button.title = "L"
      }
      button.toolTip = "Layouts"
    }

    item.menu = makeMenu()
    statusItem = item
  }

  private func makeMenu() -> NSMenu {
    let menu = NSMenu()
    menu.addItem(menuItem("Settings…", action: #selector(settings)))
    menu.addItem(.separator())
    menu.addItem(menuItem("Quit Layouts", action: #selector(quit)))
    return menu
  }

  private func menuItem(_ title: String, action: Selector) -> NSMenuItem {
    let item = NSMenuItem(title: title, action: action, keyEquivalent: "")
    item.target = self
    return item
  }

  @objc private func settings() { onSettings() }
  @objc private func quit() { NSApp.terminate(nil) }
}
