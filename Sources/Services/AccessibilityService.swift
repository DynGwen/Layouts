import AppKit
import ApplicationServices
import Combine
import Foundation

/// Shared reference storage keeps permission refreshes independent of State macros.
@MainActor
final class AccessibilityStatus: ObservableObject {
  static let shared = AccessibilityStatus()

  @Published private(set) var accessibilityGranted = AccessibilityService.isTrusted

  private init() {}

  func refresh() {
    accessibilityGranted = AccessibilityService.isTrusted
  }
}

enum AccessibilityService {
  static var isTrusted: Bool {
    AXIsProcessTrusted()
  }

  @discardableResult
  static func requestAccess(prompt: Bool = true) -> Bool {
    let options =
      [
        kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: prompt
      ] as CFDictionary

    return AXIsProcessTrustedWithOptions(options)
  }

  static func openSystemSettings() {
    guard
      let url = URL(
        string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility"
      )
    else {
      return
    }

    NSWorkspace.shared.open(url)
  }
}
