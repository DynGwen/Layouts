import Foundation

/// Represents the four visual drop targets available in the overlay.
enum LayoutAction: CaseIterable, Equatable {
  case full
  case left
  case right
  case centered

  static var dropTargets: [LayoutAction] {
    [.full, .left, .right, .centered]
  }

  var displayName: String {
    switch self {
    case .full: return "Full Screen"
    case .left: return "Left"
    case .right: return "Right"
    case .centered: return "Centered"
    }
  }
}
