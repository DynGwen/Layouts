import Foundation

enum MenuPanelGeometry {
  static func frame(
    for contentSize: CGSize, anchoredTo anchor: CGRect, in visibleFrame: CGRect
  ) -> CGRect {
    let bounds = visibleFrame.insetBy(dx: 8, dy: 8)
    let size = CGSize(
      width: min(contentSize.width, max(1, bounds.width)),
      height: min(contentSize.height, max(1, bounds.height))
    )
    return CGRect(
      x: min(max(anchor.midX - size.width / 2, bounds.minX), bounds.maxX - size.width),
      y: min(max(anchor.minY - 8 - size.height, bounds.minY), bounds.maxY - size.height),
      width: size.width,
      height: size.height
    )
  }
}
