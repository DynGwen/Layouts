import AppKit
import ApplicationServices
import Foundation

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
