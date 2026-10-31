import Foundation

/// Resolves strings for the edition fixed in the application bundle.
enum L10n {
  enum Key: String, CaseIterable {
    case optionsTitle = "options.title"
    case margin = "settings.margin"
    case centeredSize = "settings.centeredSize"
    case showMenuIcon = "settings.showMenuIcon"
    case launchAtLogin = "settings.launchAtLogin"
    case permissionRequired = "permission.required"
    case allow = "permission.allow"
    case permissionHelp = "permission.help"
    case systemSettings = "permission.systemSettings"
    case ready = "menu.ready"
    case options = "menu.options"
    case quit = "menu.quit"
    case menuHint = "menu.hint"
    case full = "layout.full"
    case left = "layout.left"
    case right = "layout.right"
    case centered = "layout.centered"
    case points = "value.points"
    case percent = "value.percent"
    case percentSpoken = "value.percentSpoken"
  }

  static func string(
    _ key: Key, language: AppLanguage, bundle: Bundle = .main
  ) -> String {
    let code = language.localizationCode
    let localizedBundle = bundle.path(forResource: code, ofType: "lproj")
      .flatMap { Bundle(path: $0) } ?? bundle
    return localizedBundle.localizedString(forKey: key.rawValue, value: nil, table: nil)
  }

  static func number(
    _ key: Key, _ value: Int, language: AppLanguage, bundle: Bundle = .main
  ) -> String {
    String(
      format: string(key, language: language, bundle: bundle),
      locale: Locale(identifier: language.localizationCode),
      value
    )
  }
}
