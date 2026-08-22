import AppKit
import SwiftUI

/// Displays the user-facing preferences in English.
struct SettingsView: View {
  @ObservedObject private var preferences = AppPreferences.shared
  @ObservedObject private var loginItemService = LoginItemService.shared
  @State private var accessibilityGranted = AccessibilityService.isTrusted

  var body: some View {
    VStack(alignment: .leading, spacing: 20) {
      header
      Divider()
      dragSection
      marginSection
      centeredLayoutSection
      behaviorSection
      permissionSection

      if let error = loginItemService.lastError {
        Text(error)
          .font(.caption)
          .foregroundStyle(.secondary)
          .fixedSize(horizontal: false, vertical: true)
      }
    }
    .padding(24)
    .frame(width: 470)
    .onAppear { refreshState() }
    .onReceive(
      NotificationCenter.default.publisher(
        for: NSApplication.didBecomeActiveNotification
      )
    ) { _ in
      refreshState()
    }
  }

  private var header: some View {
    VStack(alignment: .leading, spacing: 4) {
      Text("Layouts")
        .font(.title2.bold())
      Text("Arrange your windows with simple drag and drop.")
        .foregroundStyle(.secondary)
    }
  }

  private var dragSection: some View {
    VStack(alignment: .leading, spacing: 8) {
      Text("Drag and Drop")
        .font(.headline)
      Text(
        "Move a window normally. The four layout targets automatically appear on the right side of the screen. Release the mouse over the desired target to apply the layout."
      )
      .font(.callout)
      .foregroundStyle(.secondary)
      .fixedSize(horizontal: false, vertical: true)
    }
  }

  private var marginSection: some View {
    VStack(alignment: .leading, spacing: 8) {
      Text("Window Margin")
        .font(.headline)

      HStack(spacing: 12) {
        Slider(value: $preferences.margin, in: 0...40, step: 1)
        Text("\(Int(preferences.margin)) pt")
          .monospacedDigit()
          .frame(width: 48, alignment: .trailing)
      }
    }
  }

  private var centeredLayoutSection: some View {
    VStack(alignment: .leading, spacing: 8) {
      Text("Centered Layout Size")
        .font(.headline)

      HStack(spacing: 12) {
        Slider(value: $preferences.centeredScale, in: 0.30...1.00, step: 0.05)
        Text("\(Int((preferences.centeredScale * 100).rounded())) %")
          .monospacedDigit()
          .frame(width: 48, alignment: .trailing)
      }

      Text("The percentage applies to both width and height.")
        .font(.caption)
        .foregroundStyle(.secondary)
    }
  }

  private var behaviorSection: some View {
    VStack(alignment: .leading, spacing: 10) {
      Text("General")
        .font(.headline)

      Toggle(
        "Show menu bar icon",
        isOn: $preferences.showMenuBarIcon
      )

      Toggle(
        "Launch Layouts at login",
        isOn: Binding(
          get: { loginItemService.isEnabled },
          set: { loginItemService.setEnabled($0) }
        )
      )

      if loginItemService.lastError != nil {
        Button("Open Login Items Settings") {
          loginItemService.openSystemSettings()
        }
        .buttonStyle(.link)
      }
    }
  }

  private var permissionSection: some View {
    VStack(alignment: .leading, spacing: 8) {
      Text("Accessibility")
        .font(.headline)

      HStack {
        Image(
          systemName: accessibilityGranted
            ? "checkmark.circle.fill"
            : "exclamationmark.triangle.fill"
        )
        Text(
          accessibilityGranted
            ? "Permission granted"
            : "Permission required"
        )
        Spacer()

        if accessibilityGranted {
          Button("Check") { refreshState() }
        } else {
          Button("Allow") {
            _ = AccessibilityService.requestAccess(prompt: true)
            AccessibilityService.openSystemSettings()
          }
        }
      }
    }
  }

  private func refreshState() {
    accessibilityGranted = AccessibilityService.isTrusted
    loginItemService.refresh()
  }
}
