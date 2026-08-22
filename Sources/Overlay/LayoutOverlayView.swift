import AppKit

final class LayoutOverlayView: NSView {
  private(set) var dropZones: [LayoutDropZone] = []
  var hoveredAction: LayoutAction? {
    didSet {
      if oldValue != hoveredAction {
        needsDisplay = true
      }
    }
  }

  override var isFlipped: Bool { true }

  override init(frame frameRect: NSRect) {
    super.init(frame: frameRect)
    wantsLayer = true
    layer?.masksToBounds = false
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func layout() {
    super.layout()
    rebuildDropZones()
  }

  override func draw(_ dirtyRect: NSRect) {
    super.draw(dirtyRect)

    for zone in dropZones {
      drawCard(for: zone)
    }
  }

  func action(at localPoint: CGPoint) -> LayoutAction? {
    dropZones.first(where: { $0.frame.contains(localPoint) })?.action
  }

  private func rebuildDropZones() {
    let horizontalInset: CGFloat = 10
    let verticalInset: CGFloat = 10
    let gap: CGFloat = 10
    let count = CGFloat(LayoutAction.dropTargets.count)
    let availableHeight = bounds.height - (verticalInset * 2) - (gap * (count - 1))
    let cardHeight = floor(availableHeight / count)
    let cardWidth = bounds.width - (horizontalInset * 2)

    dropZones = LayoutAction.dropTargets.enumerated().map { index, action in
      LayoutDropZone(
        action: action,
        frame: CGRect(
          x: horizontalInset,
          y: verticalInset + CGFloat(index) * (cardHeight + gap),
          width: cardWidth,
          height: cardHeight
        )
      )
    }
  }

  private func drawCard(for zone: LayoutDropZone) {
    let isHovered = hoveredAction == zone.action
    let cardPath = NSBezierPath(roundedRect: zone.frame, xRadius: 15, yRadius: 15)

    NSGraphicsContext.saveGraphicsState()
    let shadow = NSShadow()
    shadow.shadowBlurRadius = isHovered ? 18 : 10
    shadow.shadowOffset = NSSize(width: 0, height: -2)
    shadow.shadowColor = NSColor.black.withAlphaComponent(isHovered ? 0.30 : 0.18)
    shadow.set()

    NSColor.white.withAlphaComponent(isHovered ? 0.34 : 0.18).setFill()
    cardPath.fill()
    NSGraphicsContext.restoreGraphicsState()

    NSColor.white.withAlphaComponent(isHovered ? 0.95 : 0.55).setStroke()
    cardPath.lineWidth = isHovered ? 1.5 : 1
    cardPath.stroke()

    let miniature = zone.frame.insetBy(dx: 18, dy: 14)
    drawMiniature(for: zone.action, in: miniature, hovered: isHovered)
  }

  private func drawMiniature(
    for action: LayoutAction,
    in frame: CGRect,
    hovered: Bool
  ) {
    let screenPath = NSBezierPath(roundedRect: frame, xRadius: 5, yRadius: 5)
    NSColor.white.withAlphaComponent(hovered ? 0.58 : 0.34).setStroke()
    screenPath.lineWidth = 1
    screenPath.stroke()

    let inset: CGFloat = 4
    let content = frame.insetBy(dx: inset, dy: inset)
    let target: CGRect

    switch action {
    case .full:
      target = content
    case .left:
      target = CGRect(
        x: content.minX,
        y: content.minY,
        width: content.width * 0.48,
        height: content.height
      )
    case .right:
      target = CGRect(
        x: content.maxX - content.width * 0.48,
        y: content.minY,
        width: content.width * 0.48,
        height: content.height
      )
    case .centered:
      target = LayoutEngine.centeredScaledFrame(
        in: content,
        scale: CGFloat(AppPreferences.shared.centeredScale)
      )
    }

    let targetPath = NSBezierPath(roundedRect: target, xRadius: 3, yRadius: 3)
    NSColor.white.withAlphaComponent(hovered ? 0.92 : 0.64).setFill()
    targetPath.fill()
  }
}
