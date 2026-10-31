import Foundation

/// Build-edition metadata, not a user preference or system-language selection.
enum AppLanguage: String, CaseIterable, Hashable {
  case french = "fr"
  case english = "en"

  var localizationCode: String { rawValue }

  static func edition(in bundle: Bundle = .main) -> AppLanguage {
    let code = bundle.object(forInfoDictionaryKey: "LayoutsLanguage") as? String
    return code.flatMap { AppLanguage(rawValue: $0) } ?? .english
  }
}
