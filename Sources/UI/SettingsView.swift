import AppKit
import SwiftUI

/// The options window contains only the two application behavior preferences.
struct SettingsView: View {
  @ObservedObject private var preferences = AppPreferences.shared
  @ObservedObject private var loginItemService = LoginItemService.shared

  var body: some View {
    VStack(alignment: .leading, spacing: 14) {
      Toggle(text(.showMenuIcon), isOn: $preferences.showMenuBarIcon)

      Toggle(
        text(.launchAtLogin),
        isOn: Binding(
          get: { loginItemService.isEnabled },
          set: { loginItemService.setEnabled($0) }
        )
      )

      if let error = loginItemService.lastError {
        Text(error)
          .font(.caption)
          .foregroundStyle(.secondary)
          .fixedSize(horizontal: false, vertical: true)
      }
    }
    .toggleStyle(.checkbox)
    .padding(20)
    .frame(minWidth: 400, minHeight: 110, alignment: .leading)
    .environment(\.locale, Locale(identifier: preferences.language.localizationCode))
    .onAppear { loginItemService.refresh() }
    .onReceive(
      NotificationCenter.default.publisher(for: NSApplication.didBecomeActiveNotification)
    ) { _ in
      loginItemService.refresh()
    }
  }

  private func text(_ key: L10n.Key) -> String {
    L10n.string(key, language: preferences.language)
  }
}
