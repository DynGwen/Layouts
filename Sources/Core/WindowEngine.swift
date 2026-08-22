import AppKit
import Foundation

/// Applies layout frames to Accessibility windows on a dedicated work queue.
final class WindowEngine {
  private let queue = DispatchQueue(
    label: "com.layouts.window-engine",
    qos: .userInitiated
  )
  private let accessibilityClient = AccessibilityClient()
  private let preferences: AppPreferences
  private let onPermissionRequired: () -> Void

  init(
    preferences: AppPreferences,
    onPermissionRequired: @escaping () -> Void
  ) {
    self.preferences = preferences
    self.onPermissionRequired = onPermissionRequired
  }

  func perform(
    _ action: LayoutAction,
    on window: AccessibilityClient.WindowHandle,
    targetScreenID: UInt32? = nil
  ) {
    guard Thread.isMainThread else {
      DispatchQueue.main.async { [weak self] in
        self?.perform(
          action,
          on: window,
          targetScreenID: targetScreenID
        )
      }
      return
    }

    guard AccessibilityService.isTrusted else {
      onPermissionRequired()
      return
    }

    let snapshot = ScreenSnapshotProvider.capture()
    let margin = CGFloat(preferences.margin)
    let centeredScale = CGFloat(preferences.centeredScale)

    queue.async { [weak self] in
      self?.perform(
        action,
        on: window,
        targetScreenID: targetScreenID,
        screenSnapshot: snapshot,
        margin: margin,
        centeredScale: centeredScale
      )
    }
  }

  private func perform(
    _ action: LayoutAction,
    on window: AccessibilityClient.WindowHandle,
    targetScreenID: UInt32?,
    screenSnapshot: ScreenSnapshot,
    margin: CGFloat,
    centeredScale: CGFloat
  ) {
    guard let currentAXFrame = accessibilityClient.frame(of: window) else {
      return
    }

    let currentAppKitFrame = CoordinateConverter.accessibilityToAppKit(
      currentAXFrame,
      mainScreenTop: screenSnapshot.mainScreenTop
    )

    let screen = targetScreenID.flatMap { targetID in
      screenSnapshot.screens.first(where: { $0.id == targetID })
    } ?? ScreenResolver.screen(
      containing: currentAppKitFrame,
      from: screenSnapshot.screens
    )

    guard
      let screen,
      let targetAppKitFrame = LayoutEngine.frame(
        for: action,
        screen: screen,
        margin: margin,
        centeredScale: centeredScale
      )
    else {
      return
    }

    let targetAXFrame = CoordinateConverter.appKitToAccessibility(
      targetAppKitFrame,
      mainScreenTop: screenSnapshot.mainScreenTop
    )
    _ = accessibilityClient.setFrame(targetAXFrame, of: window)

    // Some applications enforce their own size constraints. Read back the
    // accepted size, then restore the semantic anchor so centered layouts
    // remain visually centered after the resize.
    settleAnchor(
      for: action,
      window: window,
      targetAppKitFrame: targetAppKitFrame,
      screenSnapshot: screenSnapshot
    )
  }

  private func settleAnchor(
    for action: LayoutAction,
    window: AccessibilityClient.WindowHandle,
    targetAppKitFrame: CGRect,
    screenSnapshot: ScreenSnapshot
  ) {
    // Two passes handle applications that clamp the first Accessibility move.
    for _ in 0..<2 {
      guard let actualAXFrame = accessibilityClient.frame(of: window) else {
        return
      }

      let actualAppKitFrame = CoordinateConverter.accessibilityToAppKit(
        actualAXFrame,
        mainScreenTop: screenSnapshot.mainScreenTop
      )
      let desiredOrigin = LayoutEngine.anchoredOrigin(
        for: action,
        targetFrame: targetAppKitFrame,
        actualSize: actualAppKitFrame.size
      )
      let correctedAppKitFrame = CGRect(
        origin: desiredOrigin,
        size: actualAppKitFrame.size
      )
      let correctedAXFrame = CoordinateConverter.appKitToAccessibility(
        correctedAppKitFrame,
        mainScreenTop: screenSnapshot.mainScreenTop
      )

      let dx = abs(actualAXFrame.minX - correctedAXFrame.minX)
      let dy = abs(actualAXFrame.minY - correctedAXFrame.minY)
      guard dx > 0.5 || dy > 0.5 else {
        return
      }

      _ = accessibilityClient.setPosition(
        correctedAXFrame.origin,
        of: window
      )
    }
  }
}
