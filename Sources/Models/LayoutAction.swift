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

  func displayName(in language: AppLanguage) -> String {
    switch self {
    case .full: return L10n.string(.full, language: language)
    case .left: return L10n.string(.left, language: language)
    case .right: return L10n.string(.right, language: language)
    case .centered: return L10n.string(.centered, language: language)
    }
  }
}
