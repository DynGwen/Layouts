import AppKit
import Combine
import SwiftUI

private final class LayoutsMenuPanel: NSPanel {
  override var canBecomeKey: Bool { true }
  override var canBecomeMain: Bool { false }
}

/// Owns the optional status item and its compact, interactive glass panel.
@MainActor
final class MenuBarController: NSObject {
  private let preferences: AppPreferences
  private let onSettings: () -> Void
  private let state = AccessibilityStatus.shared
  private let panel = LayoutsMenuPanel(
    contentRect: .zero,
    styleMask: [.borderless, .nonactivatingPanel],
    backing: .buffered,
    defer: false
  )

  private var statusItem: NSStatusItem?
  private var subscriptions = Set<AnyCancellable>()
  private var globalMouseMonitor: Any?
  private var localEventMonitor: Any?
  private var layoutTask: Task<Void, Never>?

  init(preferences: AppPreferences, onSettings: @escaping () -> Void) {
    self.preferences = preferences
    self.onSettings = onSettings
    super.init()

    panel.isOpaque = false
    panel.backgroundColor = .clear
    panel.hasShadow = true
    panel.level = .statusBar
    panel.hidesOnDeactivate = false
    panel.isReleasedWhenClosed = false
    panel.isFloatingPanel = true
    panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary, .transient]
    panel.contentView = NSHostingView(
      rootView: MenuContentView(
        preferences: preferences, state: state,
        onOptions: { [weak self] in
          self?.closeMenu()
          self?.onSettings()
        },
        onQuit: { NSApp.terminate(nil) }
      )
    )

    preferences.$showMenuBarIcon
      .removeDuplicates()
      .receive(on: RunLoop.main)
      .sink { [weak self] visible in self?.setVisible(visible) }
      .store(in: &subscriptions)

    preferences.objectWillChange
      .merge(with: state.objectWillChange)
      .receive(on: RunLoop.main)
      .sink { [weak self] _ in self?.scheduleLayout() }
      .store(in: &subscriptions)

    installEventMonitors()
    NSWorkspace.shared.notificationCenter.addObserver(
      self,
      selector: #selector(activeApplicationDidChange(_:)),
      name: NSWorkspace.didActivateApplicationNotification,
      object: nil
    )
  }

  func stop() {
    layoutTask?.cancel()
    subscriptions.removeAll()
    if let globalMouseMonitor { NSEvent.removeMonitor(globalMouseMonitor) }
    if let localEventMonitor { NSEvent.removeMonitor(localEventMonitor) }
    globalMouseMonitor = nil
    localEventMonitor = nil
    NSWorkspace.shared.notificationCenter.removeObserver(
      self, name: NSWorkspace.didActivateApplicationNotification, object: nil
    )
    closeMenu()
    if let statusItem { NSStatusBar.system.removeStatusItem(statusItem) }
    statusItem = nil
  }

  private func setVisible(_ visible: Bool) {
    if visible {
      createStatusItemIfNeeded()
    } else {
      closeMenu()
      if let statusItem { NSStatusBar.system.removeStatusItem(statusItem) }
      statusItem = nil
    }
  }

  private func createStatusItemIfNeeded() {
    guard statusItem == nil else { return }
    let item = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
    item.autosaveName = "Layouts.statusItem"
    if let button = item.button {
      if let image = NSImage(
        systemSymbolName: "rectangle.3.group", accessibilityDescription: "Layouts"
      ) {
        image.isTemplate = true
        button.image = image
      } else {
        button.title = "L"
      }
      button.toolTip = "Layouts"
      button.setAccessibilityLabel("Layouts")
      button.target = self
      button.action = #selector(toggleMenu)
      button.sendAction(on: [.leftMouseUp, .rightMouseUp])
    }
    statusItem = item
  }

  @objc private func toggleMenu() {
    // Only this action toggles the panel for a status-button click.
    if panel.isVisible {
      closeMenu()
      return
    }
    state.refresh()
    guard positionPanel() else { return }
    statusItem?.button?.highlight(true)
    panel.makeKeyAndOrderFront(nil)
    scheduleLayout()
  }

  private func closeMenu() {
    layoutTask?.cancel()
    panel.orderOut(nil)
    statusItem?.button?.highlight(false)
  }

  @objc private func activeApplicationDidChange(_ notification: Notification) {
    guard let application = notification.userInfo?[
      NSWorkspace.applicationUserInfoKey
    ] as? NSRunningApplication,
      application.processIdentifier != ProcessInfo.processInfo.processIdentifier
    else { return }
    closeMenu()
  }

  private func scheduleLayout() {
    guard panel.isVisible else { return }
    layoutTask?.cancel()
    layoutTask = Task { @MainActor [weak self] in
      do { try await Task.sleep(nanoseconds: 30_000_000) }
      catch { return }
      guard let self, self.panel.isVisible, !Task.isCancelled else { return }
      _ = self.positionPanel()
    }
  }

  @discardableResult
  private func positionPanel() -> Bool {
    guard let button = statusItem?.button, let buttonWindow = button.window,
      let screen = buttonWindow.screen, let content = panel.contentView
    else { return false }
    content.layoutSubtreeIfNeeded()
    let size = content.fittingSize
    guard size.width > 0, size.height > 0 else { return false }
    let anchor = buttonWindow.convertToScreen(button.convert(button.bounds, to: nil))
    panel.setFrame(
      MenuPanelGeometry.frame(for: size, anchoredTo: anchor, in: screen.visibleFrame),
      display: true
    )
    return true
  }

  private func installEventMonitors() {
    globalMouseMonitor = NSEvent.addGlobalMonitorForEvents(
      matching: [.leftMouseDown, .rightMouseDown, .otherMouseDown]
    ) { [weak self] event in
      // AppKit runs both monitors on the main thread. Handle the event now so
      // an old outside click cannot close a panel opened by a later click.
      MainActor.assumeIsolated {
        _ = self?.handleEvent(event)
      }
    }
    localEventMonitor = NSEvent.addLocalMonitorForEvents(
      matching: [.leftMouseDown, .rightMouseDown, .otherMouseDown, .keyDown]
    ) { [weak self] event in
      // Keep the SDK's non-Sendable NSEvent in AppKit's main-thread callback.
      let consumed = MainActor.assumeIsolated {
        self?.handleEvent(event) ?? false
      }
      return consumed ? nil : event
    }
  }

  private func handleEvent(_ event: NSEvent) -> Bool {
    if event.type == .keyDown {
      if event.keyCode == 53, panel.isVisible {
        closeMenu()
        return true
      }
      return false
    }
    // Do not dismiss on the icon's mouse-down: its mouse-up action must see
    // the current visibility, even when AppKit has already moved key focus.
    if event.window !== panel, !isStatusButtonEvent(event) { closeMenu() }
    return false
  }

  private func isStatusButtonEvent(_ event: NSEvent) -> Bool {
    guard let button = statusItem?.button, let buttonWindow = button.window
    else { return false }
    let point = event.window?.convertPoint(toScreen: event.locationInWindow)
      ?? event.locationInWindow
    let frame = buttonWindow.convertToScreen(button.convert(button.bounds, to: nil))
    return frame.contains(point)
  }
}
