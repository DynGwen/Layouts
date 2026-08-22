import Combine
import Foundation
import ServiceManagement

final class LoginItemService: ObservableObject {
  static let shared = LoginItemService()

  @Published private(set) var isEnabled = false
  @Published private(set) var lastError: String?

  private init() {
    refresh()
  }

  func refresh() {
    isEnabled = SMAppService.mainApp.status == .enabled
  }

  func setEnabled(_ enabled: Bool) {
    do {
      if enabled {
        try SMAppService.mainApp.register()
      } else {
        try SMAppService.mainApp.unregister()
      }
      lastError = nil
    } catch {
      lastError = error.localizedDescription
    }

    refresh()
  }

  func openSystemSettings() {
    SMAppService.openSystemSettingsLoginItems()
  }
}
