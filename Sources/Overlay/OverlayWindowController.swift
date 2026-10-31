import AppKit

final class OverlayWindowController {
  private let panel: NSPanel
  private let overlayView: LayoutOverlayView

  init() {
    let initialFrame = CGRect(x: 0, y: 0, width: 126, height: 410)
    overlayView = LayoutOverlayView(frame: initialFrame)

    panel = LayoutOverlayPanel(
      contentRect: initialFrame,
      styleMask: [.borderless, .nonactivatingPanel],
      backing: .buffered,
      defer: true
    )
    panel.contentView = overlayView
    panel.isOpaque = false
    panel.backgroundColor = .clear
    panel.hasShadow = false
    panel.level = .floating
    panel.ignoresMouseEvents = true
    panel.hidesOnDeactivate = false
    panel.collectionBehavior = [
      .canJoinAllSpaces,
      .fullScreenAuxiliary,
      .ignoresCycle
    ]
    panel.animationBehavior = .none
    panel.alphaValue = 0
  }

  var isVisible: Bool {
    panel.isVisible
  }

  func show(on screen: ScreenGeometry) {
    // Re-evaluate even on the same display after a Dock or resolution change.
    position(on: screen)

    guard !panel.isVisible else {
      return
    }

    overlayView.hoveredAction = nil
    panel.alphaValue = 0
    panel.orderFrontRegardless()

    if NSWorkspace.shared.accessibilityDisplayShouldReduceMotion {
      panel.alphaValue = 1
      return
    }

    NSAnimationContext.runAnimationGroup { context in
      context.duration = 0.12
      panel.animator().alphaValue = 1
    }
  }

  func hide() {
    guard panel.isVisible else {
      return
    }

    overlayView.hoveredAction = nil
    panel.alphaValue = 0
    panel.orderOut(nil)
  }

  func updateHover(mouseLocation: CGPoint) -> LayoutAction? {
    guard panel.isVisible else {
      return nil
    }

    overlayView.layoutSubtreeIfNeeded()
    let windowPoint = panel.convertPoint(fromScreen: mouseLocation)
    let local = overlayView.convert(windowPoint, from: nil)
    let action = overlayView.action(at: local)
    overlayView.hoveredAction = action
    return action
  }

  private func position(on screen: ScreenGeometry) {
    let frame = LayoutOverlayGeometry.panelFrame(on: screen)
    if panel.frame != frame {
      panel.setFrame(frame, display: true)
    }
  }
}

private final class LayoutOverlayPanel: NSPanel {
  override var canBecomeKey: Bool { false }
  override var canBecomeMain: Bool { false }
}
