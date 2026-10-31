import Combine
import Foundation

final class AppPreferences: ObservableObject {
  static let shared = AppPreferences()

  private enum Key {
    static let margin = "margin"
    static let showMenuBarIcon = "showMenuBarIcon"
    static let centeredScale = "centeredScale"
  }

  private let defaults: UserDefaults

  /// Fixed by the FR or EN edition; old saved language preferences are ignored.
  let language: AppLanguage

  @Published var margin: Double {
    didSet {
      defaults.set(margin, forKey: Key.margin)
    }
  }

  @Published var centeredScale: Double {
    didSet {
      defaults.set(centeredScale, forKey: Key.centeredScale)
    }
  }

  @Published var showMenuBarIcon: Bool {
    didSet {
      defaults.set(showMenuBarIcon, forKey: Key.showMenuBarIcon)
    }
  }

  init(defaults: UserDefaults = .standard) {
    self.defaults = defaults

    language = AppLanguage.edition()

    let storedMargin: Double
    if defaults.object(forKey: Key.margin) == nil {
      storedMargin = 12
    } else {
      storedMargin = defaults.double(forKey: Key.margin)
    }
    margin = min(max(storedMargin, 0), 40)

    let storedCenteredScale: Double
    if defaults.object(forKey: Key.centeredScale) == nil {
      storedCenteredScale = 0.60
    } else {
      storedCenteredScale = defaults.double(forKey: Key.centeredScale)
    }
    centeredScale = min(max(storedCenteredScale, 0.30), 1.00)

    if defaults.object(forKey: Key.showMenuBarIcon) == nil {
      showMenuBarIcon = true
    } else {
      showMenuBarIcon = defaults.bool(forKey: Key.showMenuBarIcon)
    }
  }
}
