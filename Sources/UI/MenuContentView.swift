import AppKit
import Combine
import SwiftUI

/// Compact controls arranged like the user's EvniaControl menu.
struct MenuContentView: View {
  @ObservedObject var preferences: AppPreferences
  @ObservedObject var state: AccessibilityStatus
  let onOptions: () -> Void
  let onQuit: () -> Void

  var body: some View {
    VStack(alignment: .leading, spacing: 14) {
      header
      Divider()

      controlRow(
        icon: "rectangle.inset.filled", title: text(.margin),
        value: "\(Int(preferences.margin)) pt",
        spokenValue: L10n.number(.points, Int(preferences.margin), language: preferences.language),
        binding: $preferences.margin, range: 0...40, step: 1
      )

      controlRow(
        icon: "rectangle.center.inset.filled", title: text(.centeredSize),
        value: L10n.number(.percent, centeredPercent, language: preferences.language),
        spokenValue: L10n.number(.percentSpoken, centeredPercent, language: preferences.language),
        binding: $preferences.centeredScale, range: 0.30...1.00, step: 0.05
      )

      Text(text(.menuHint))
        .font(.caption)
        .foregroundStyle(.secondary)
        .fixedSize(horizontal: false, vertical: true)

      if !state.accessibilityGranted {
        Divider()
        VStack(alignment: .leading, spacing: 7) {
          Label(text(.permissionRequired), systemImage: "hand.raised.fill")
            .font(.callout.bold())
          Text(text(.permissionHelp))
            .font(.caption)
            .foregroundStyle(.secondary)
            .fixedSize(horizontal: false, vertical: true)
          HStack {
            Button(text(.allow)) {
              _ = AccessibilityService.requestAccess(prompt: true)
              AccessibilityService.openSystemSettings()
            }
            Button(text(.systemSettings)) {
              AccessibilityService.openSystemSettings()
            }
          }
        }
      }

      Divider()
      HStack {
        Button(text(.options), action: onOptions)
        Spacer()
        Button(text(.quit), action: onQuit)
      }
    }
    .padding(16)
    .frame(width: 340)
    .modifier(MenuSurfaceModifier())
    .environment(\.locale, Locale(identifier: preferences.language.localizationCode))
  }

  private var header: some View {
    HStack(spacing: 10) {
      Image(systemName: "rectangle.3.group")
        .font(.title2)
        .accessibilityHidden(true)
      VStack(alignment: .leading, spacing: 2) {
        Text("Layouts").font(.headline)
        Text(text(state.accessibilityGranted ? .ready : .permissionRequired))
          .font(.caption)
          .foregroundStyle(state.accessibilityGranted ? Color.secondary : Color.orange)
          .fixedSize(horizontal: false, vertical: true)
      }
      Spacer()
      Circle()
        .fill(state.accessibilityGranted ? Color.green : Color.orange)
        .frame(width: 9, height: 9)
        .accessibilityHidden(true)
    }
  }

  private func controlRow(
    icon: String, title: String, value: String, spokenValue: String,
    binding: Binding<Double>, range: ClosedRange<Double>, step: Double
  ) -> some View {
    VStack(alignment: .leading, spacing: 6) {
      HStack {
        Label(title, systemImage: icon)
          .lineLimit(2)
        Spacer(minLength: 8)
        Text(value)
          .monospacedDigit()
          .foregroundStyle(.secondary)
          .fixedSize()
      }
      // Reuse EvniaControl's system-style track and Liquid Glass thumb.
      TahoePillSlider(value: binding, range: range, step: step)
        .accessibilityLabel(title)
        .accessibilityValue(spokenValue)
    }
  }

  private var centeredPercent: Int {
    Int((preferences.centeredScale * 100).rounded())
  }

  private func text(_ key: L10n.Key) -> String {
    L10n.string(key, language: preferences.language)
  }
}

private struct MenuSurfaceModifier: ViewModifier {
  @Environment(\.accessibilityReduceTransparency) private var reduceTransparency

  @ViewBuilder
  func body(content: Content) -> some View {
    let shape = RoundedRectangle(cornerRadius: 16, style: .continuous)
    if reduceTransparency {
      content.background(Color(nsColor: .windowBackgroundColor), in: shape)
    } else if #available(macOS 26.0, *) {
      content.glassEffect(.regular, in: shape)
    } else {
      content.background(.regularMaterial, in: shape)
    }
  }
}
