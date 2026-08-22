import Foundation

struct ScreenGeometry: Sendable {
  let id: UInt32
  let frame: CGRect
  let visibleFrame: CGRect
}

struct ScreenSnapshot: Sendable {
  let screens: [ScreenGeometry]
  let mainScreenTop: CGFloat
}
