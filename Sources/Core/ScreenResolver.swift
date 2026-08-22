import Foundation

enum ScreenResolver {
  static func screen(
    containing frame: CGRect,
    from screens: [ScreenGeometry]
  ) -> ScreenGeometry? {
    guard !screens.isEmpty else {
      return nil
    }

    let center = CGPoint(x: frame.midX, y: frame.midY)
    if let containing = screen(containing: center, from: screens) {
      return containing
    }

    return screens.max { lhs, rhs in
      intersectionArea(lhs.frame, frame) < intersectionArea(rhs.frame, frame)
    }
  }

  static func screen(
    containing point: CGPoint,
    from screens: [ScreenGeometry]
  ) -> ScreenGeometry? {
    if let exact = screens.first(where: { $0.frame.contains(point) }) {
      return exact
    }

    return screens.min { lhs, rhs in
      distanceSquared(point, lhs.frame) < distanceSquared(point, rhs.frame)
    }
  }

  private static func intersectionArea(_ lhs: CGRect, _ rhs: CGRect) -> CGFloat {
    let intersection = lhs.intersection(rhs)
    guard !intersection.isNull else {
      return 0
    }
    return intersection.width * intersection.height
  }

  private static func distanceSquared(_ point: CGPoint, _ rect: CGRect) -> CGFloat {
    let x = min(max(point.x, rect.minX), rect.maxX)
    let y = min(max(point.y, rect.minY), rect.maxY)
    let dx = point.x - x
    let dy = point.y - y
    return dx * dx + dy * dy
  }
}
