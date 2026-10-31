import AppKit
import Combine
import SwiftUI

private final class LayoutsMenuPanel: NSPanel {
  override var canBecomeKey: Bool { true }
  override var canBecomeMain: Bool { false }
}

/// Owns the optional status item and its compact, interactive glass panel.
@MainActor
final class MenuBarController: NSObject, NSWindowDelegate {
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
  private var menuVisibleAtButtonMouseDown = false

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
    panel.delegate = self
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
  }

  func stop() {
    layoutTask?.cancel()
    subscriptions.removeAll()
    if let globalMouseMonitor { NSEvent.removeMonitor(globalMouseMonitor) }
    if let localEventMonitor { NSEvent.removeMonitor(localEventMonitor) }
    globalMouseMonitor = nil
    localEventMonitor = nil
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
    // A status-button click can resign the panel's key status before mouse-up.
    let shouldClose = panel.isVisible || menuVisibleAtButtonMouseDown
    menuVisibleAtButtonMouseDown = false
    if shouldClose {
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

  func windowDidResignKey(_ notification: Notification) {
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
    ) { [weak self] _ in
      Task { @MainActor [weak self] in self?.closeMenu() }
    }
    localEventMonitor = NSEvent.addLocalMonitorForEvents(
      matching: [.leftMouseDown, .rightMouseDown, .otherMouseDown, .keyDown]
    ) { [weak self] event in
      // Keep the SDK's non-Sendable NSEvent in AppKit's main-thread callback.
      let consumed = MainActor.assumeIsolated {
        self?.handleLocalEvent(event) ?? false
      }
      return consumed ? nil : event
    }
  }

  private func handleLocalEvent(_ event: NSEvent) -> Bool {
    if event.type == .keyDown {
      if event.keyCode == 53, panel.isVisible {
        closeMenu()
        return true
      }
      return false
    }
    if event.window === statusItem?.button?.window {
      menuVisibleAtButtonMouseDown = panel.isVisible
      return false
    }
    if event.window !== panel { closeMenu() }
    return false
  }
}
