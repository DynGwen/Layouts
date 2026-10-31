import Foundation

/// Shared visual and hit-test geometry, expressed in the overlay's flipped coordinates.
enum LayoutOverlayGeometry {
  static func dropZones(in bounds: CGRect) -> [LayoutDropZone] {
    guard bounds.width > 0, bounds.height > 0 else { return [] }

    let horizontalInset = min(10, bounds.width / 4)
    let verticalInset = min(10, bounds.height / 10)
    let count = CGFloat(LayoutAction.dropTargets.count)
    let gap = min(10, (bounds.height - verticalInset * 2) / (count * 2))
    let cardHeight = (bounds.height - verticalInset * 2 - gap * (count - 1)) / count

    return LayoutAction.dropTargets.enumerated().map { index, action in
      LayoutDropZone(
        action: action,
        frame: CGRect(
          x: bounds.minX + horizontalInset,
          y: bounds.minY + verticalInset + CGFloat(index) * (cardHeight + gap),
          width: bounds.width - horizontalInset * 2,
          height: cardHeight
        )
      )
    }
  }

  static func panelFrame(on screen: ScreenGeometry) -> CGRect {
    let visible = screen.visibleFrame
    let width = min(126, max(1, visible.width - 36))
    let height = min(410, max(1, visible.height - 40))
    let sideInset = min(18, max(0, visible.width - width))

    return CGRect(
      x: visible.maxX - width - sideInset,
      y: visible.midY - height / 2,
      width: width,
      height: height
    )
  }
}
