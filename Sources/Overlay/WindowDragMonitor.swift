import AppKit
import Foundation

final class WindowDragMonitor {
  private struct Candidate {
    let window: AccessibilityClient.WindowHandle
    let initialFrame: CGRect
  }

  private let accessibilityClient = AccessibilityClient()
  private let overlayController: OverlayWindowController
  private let windowEngine: WindowEngine
  private let applicationTracker: FrontmostApplicationTracker

  private var eventMonitor: Any?
  private var candidate: Candidate?
  private var isDraggingWindow = false

  init(
    overlayController: OverlayWindowController,
    windowEngine: WindowEngine,
    applicationTracker: FrontmostApplicationTracker
  ) {
    self.overlayController = overlayController
    self.windowEngine = windowEngine
    self.applicationTracker = applicationTracker
  }

  func start() {
    guard eventMonitor == nil else {
      return
    }

    eventMonitor = NSEvent.addGlobalMonitorForEvents(
      matching: [.leftMouseDown, .leftMouseDragged, .leftMouseUp]
    ) { [weak self] event in
      DispatchQueue.main.async {
        self?.handle(event)
      }
    }
  }

  func stop() {
    if let eventMonitor {
      NSEvent.removeMonitor(eventMonitor)
      self.eventMonitor = nil
    }
    reset()
  }

  private func handle(_ event: NSEvent) {
    guard AccessibilityService.isTrusted else {
      reset()
      return
    }

    switch event.type {
    case .leftMouseDown:
      beginCandidate()
    case .leftMouseDragged:
      updateDrag()
    case .leftMouseUp:
      finishDrag()
    default:
      break
    }
  }

  private func beginCandidate() {
    reset()

    guard let pid = applicationTracker.targetPID() else {
      return
    }
    beginCandidate(for: pid)
  }

  private func updateDrag() {
    refreshCandidateForFrontmostApplicationIfNeeded()

    guard let candidate else {
      return
    }

    if !isDraggingWindow {
      let snapshot = ScreenSnapshotProvider.capture()
      guard
        let currentAXFrame = accessibilityClient.frame(of: candidate.window)
      else {
        reset()
        return
      }

      let currentFrame = CoordinateConverter.accessibilityToAppKit(
        currentAXFrame,
        mainScreenTop: snapshot.mainScreenTop
      )

      guard looksLikeWindowMove(from: candidate.initialFrame, to: currentFrame) else {
        return
      }
      isDraggingWindow = true
    }

    updateOverlayForCurrentMouseLocation()
  }

  private func finishDrag() {
    defer { reset() }

    guard isDraggingWindow, let candidate else {
      return
    }

    let mouseLocation = NSEvent.mouseLocation
    let snapshot = ScreenSnapshotProvider.capture()
    guard
      let screen = ScreenResolver.screen(
        containing: mouseLocation,
        from: snapshot.screens
      )
    else {
      return
    }

    let action = overlayController.updateHover(mouseLocation: mouseLocation)
    guard let action else {
      return
    }

    windowEngine.perform(
      action,
      on: candidate.window,
      targetScreenID: screen.id
    )
  }

  private func updateOverlayForCurrentMouseLocation() {
    let mouseLocation = NSEvent.mouseLocation
    let snapshot = ScreenSnapshotProvider.capture()
    guard
      let screen = ScreenResolver.screen(
        containing: mouseLocation,
        from: snapshot.screens
      )
    else {
      return
    }

    overlayController.show(on: screen)
    _ = overlayController.updateHover(mouseLocation: mouseLocation)
  }

  private func reset() {
    overlayController.hide()
    candidate = nil
    isDraggingWindow = false
  }

  private func refreshCandidateForFrontmostApplicationIfNeeded() {
    guard
      let frontmostPID = NSWorkspace.shared.frontmostApplication?.processIdentifier
    else {
      return
    }

    if candidate?.window.pid != frontmostPID {
      overlayController.hide()
      beginCandidate(for: frontmostPID)
    }
  }

  private func beginCandidate(for pid: pid_t) {
    guard
      let window = accessibilityClient.focusedWindow(for: pid),
      let axFrame = accessibilityClient.frame(of: window)
    else {
      return
    }

    let snapshot = ScreenSnapshotProvider.capture()
    let appKitFrame = CoordinateConverter.accessibilityToAppKit(
      axFrame,
      mainScreenTop: snapshot.mainScreenTop
    )
    candidate = Candidate(window: window, initialFrame: appKitFrame)
    isDraggingWindow = false
  }

  private func looksLikeWindowMove(
    from initial: CGRect,
    to current: CGRect
  ) -> Bool {
    let originDelta = hypot(
      current.origin.x - initial.origin.x,
      current.origin.y - initial.origin.y
    )
    let widthDelta = abs(current.width - initial.width)
    let heightDelta = abs(current.height - initial.height)

    return originDelta >= 3 && widthDelta < 2 && heightDelta < 2
  }
}
