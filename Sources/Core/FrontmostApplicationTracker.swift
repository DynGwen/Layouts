import AppKit
import Foundation

final class FrontmostApplicationTracker {
  private let ownPID = ProcessInfo.processInfo.processIdentifier
  private let lock = NSLock()
  private var lastExternalPID: pid_t?
  private var observer: NSObjectProtocol?

  func start() {
    record(NSWorkspace.shared.frontmostApplication)

    observer = NSWorkspace.shared.notificationCenter.addObserver(
      forName: NSWorkspace.didActivateApplicationNotification,
      object: nil,
      queue: .main
    ) { [weak self] notification in
      let application =
        notification.userInfo?[
          NSWorkspace.applicationUserInfoKey
        ] as? NSRunningApplication
      self?.record(application)
    }
  }

  func stop() {
    if let observer {
      NSWorkspace.shared.notificationCenter.removeObserver(observer)
      self.observer = nil
    }
  }

  func targetPID() -> pid_t? {
    if let frontmost = NSWorkspace.shared.frontmostApplication,
      frontmost.processIdentifier != ownPID
    {
      record(frontmost)
      return frontmost.processIdentifier
    }

    lock.lock()
    defer { lock.unlock() }
    return lastExternalPID
  }

  private func record(_ application: NSRunningApplication?) {
    guard let application else {
      return
    }

    let pid = application.processIdentifier
    guard pid != ownPID else {
      return
    }

    lock.lock()
    lastExternalPID = pid
    lock.unlock()
  }

  deinit {
    stop()
  }
}
