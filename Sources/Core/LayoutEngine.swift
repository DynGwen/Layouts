import Foundation

/// Computes deterministic window frames independently from Accessibility APIs.
enum LayoutEngine {
  static func frame(
    for action: LayoutAction,
    screen: ScreenGeometry,
    margin: CGFloat,
    centeredScale: CGFloat = 0.60
  ) -> CGRect? {
    let safeMargin = max(0, margin)
    let fullFrame = inset(
      screen.visibleFrame,
      by: safeMargin
    )

    guard fullFrame.width > 0, fullFrame.height > 0 else {
      return screen.visibleFrame
    }

    switch action {
    case .full:
      return fullFrame

    case .left:
      return splitFrame(
        fullFrame,
        side: .left,
        gap: safeMargin
      )

    case .right:
      return splitFrame(
        fullFrame,
        side: .right,
        gap: safeMargin
      )

    case .centered:
      return centeredScaledFrame(
        in: fullFrame,
        scale: centeredScale
      )
    }
  }

  /// Returns a rectangle scaled from a reference frame and centered on both axes.
  static func centeredScaledFrame(
    in frame: CGRect,
    scale: CGFloat
  ) -> CGRect {
    let safeScale = min(max(scale, 0), 1)
    let width = frame.width * safeScale
    let height = frame.height * safeScale

    return CGRect(
      x: frame.midX - width / 2,
      y: frame.midY - height / 2,
      width: width,
      height: height
    )
  }


  /// Returns the origin that preserves the semantic anchor of a layout after
  /// an application has constrained the requested window size.
  static func anchoredOrigin(
    for action: LayoutAction,
    targetFrame: CGRect,
    actualSize: CGSize
  ) -> CGPoint {
    switch action {
    case .centered:
      return CGPoint(
        x: targetFrame.midX - actualSize.width / 2,
        y: targetFrame.midY - actualSize.height / 2
      )
    case .right:
      return CGPoint(
        x: targetFrame.maxX - actualSize.width,
        y: targetFrame.minY
      )
    case .full, .left:
      return targetFrame.origin
    }
  }

  private enum SplitSide {
    case left
    case right
  }

  private static func splitFrame(
    _ fullFrame: CGRect,
    side: SplitSide,
    gap: CGFloat
  ) -> CGRect {
    let effectiveGap = min(gap, max(0, fullFrame.width - 2))
    let width = max(1, (fullFrame.width - effectiveGap) / 2)

    let x: CGFloat
    switch side {
    case .left:
      x = fullFrame.minX
    case .right:
      x = fullFrame.maxX - width
    }

    return CGRect(
      x: x,
      y: fullFrame.minY,
      width: width,
      height: fullFrame.height
    )
  }

  private static func inset(
    _ rect: CGRect,
    by margin: CGFloat
  ) -> CGRect {
    let horizontal = min(margin, max(0, rect.width / 2 - 1))
    let vertical = min(margin, max(0, rect.height / 2 - 1))
    return rect.insetBy(dx: horizontal, dy: vertical)
  }
}
