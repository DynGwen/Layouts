import Foundation

@main
enum LocalizationSmokeTests {
  static func main() {
    guard CommandLine.arguments.count == 2,
      let resources = Bundle(path: CommandLine.arguments[1])
    else { fatalError("Pass the Resources directory to the localization tests") }

    guard let declaredCode = resources.object(forInfoDictionaryKey: "LayoutsLanguage") as? String,
      let declaredEdition = AppLanguage(rawValue: declaredCode),
      AppLanguage.edition(in: resources) == declaredEdition,
      AppLanguage(rawValue: "system") == nil
    else {
      fatalError("The application must declare a fixed French or English edition")
    }
    for language in [AppLanguage.french, .english] {
      for key in L10n.Key.allCases {
        let value = L10n.string(key, language: language, bundle: resources)
        guard !value.isEmpty, value != key.rawValue else {
          fatalError("Missing \(language.rawValue) translation: \(key.rawValue)")
        }
      }
    }

    expect(L10n.string(.quit, language: .french, bundle: resources), "Quitter")
    expect(L10n.string(.quit, language: .english, bundle: resources), "Quit")
    expect(L10n.string(.optionsTitle, language: .french, bundle: resources), "Options de Layouts")
    expect(L10n.string(.full, language: .french, bundle: resources), "Plein écran")
    expect(L10n.string(.full, language: .english, bundle: resources), "Full Screen")
    expect(L10n.number(.percent, 60, language: .french, bundle: resources), "60 %")
    expect(L10n.number(.percent, 60, language: .english, bundle: resources), "60%")
    expect(L10n.number(.percentSpoken, 75, language: .french, bundle: resources), "75 pour cent")
    expect(L10n.number(.percentSpoken, 75, language: .english, bundle: resources), "75 percent")
    print("Layouts French/English localization smoke tests passed")
  }

  private static func expect(_ actual: String, _ expected: String) {
    guard actual == expected else {
      fatalError("Localization: got \(actual), expected \(expected)")
    }
  }
}
