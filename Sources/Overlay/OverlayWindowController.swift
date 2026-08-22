import AppKit

final class OverlayWindowController {
  private let panel: NSPanel
  private let overlayView: LayoutOverlayView
  private var currentScreenID: UInt32?

  init() {
    let initialFrame = CGRect(x: 0, y: 0, width: 126, height: 410)
    overlayView = LayoutOverlayView(frame: initialFrame)

    panel = NSPanel(
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
    if currentScreenID != screen.id || !panel.isVisible {
      position(on: screen)
      currentScreenID = screen.id
    }

    guard !panel.isVisible else {
      return
    }

    overlayView.hoveredAction = nil
    panel.alphaValue = 0
    panel.orderFrontRegardless()

    NSAnimationContext.runAnimationGroup { context in
      context.duration = 0.12
      panel.animator().alphaValue = 1
    }
  }

  func hide() {
    guard panel.isVisible else {
      return
    }

    currentScreenID = nil
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
    let visible = screen.visibleFrame
    let sideInset: CGFloat = 18
    let width: CGFloat = 126
    let preferredHeight: CGFloat = 410
    let height = min(preferredHeight, max(260, visible.height - 40))

    let frame = CGRect(
      x: visible.maxX - width - sideInset,
      y: visible.midY - height / 2,
      width: width,
      height: height
    )
    panel.setFrame(frame, display: true)
  }
}
