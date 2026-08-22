import Foundation

enum CoordinateConverter {
  /// Accessibility coordinates use a top-left global origin, while AppKit
  /// uses a bottom-left origin. X coordinates are shared.
  static func accessibilityToAppKit(
    _ rect: CGRect,
    mainScreenTop: CGFloat
  ) -> CGRect {
    CGRect(
      x: rect.minX,
      y: mainScreenTop - rect.maxY,
      width: rect.width,
      height: rect.height
    )
  }

  static func appKitToAccessibility(
    _ rect: CGRect,
    mainScreenTop: CGFloat
  ) -> CGRect {
    CGRect(
      x: rect.minX,
      y: mainScreenTop - rect.maxY,
      width: rect.width,
      height: rect.height
    )
  }
}
