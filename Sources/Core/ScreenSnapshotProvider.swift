import AppKit
import Foundation

enum ScreenSnapshotProvider {
  static func capture() -> ScreenSnapshot {
    let screens = NSScreen.screens.map { screen in
      let number = screen.deviceDescription[NSDeviceDescriptionKey("NSScreenNumber")]
        as? NSNumber
      return ScreenGeometry(
        id: number?.uint32Value ?? 0,
        frame: screen.frame,
        visibleFrame: screen.visibleFrame
      )
    }

    let primaryScreen =
      screens.first { screen in
        abs(screen.frame.minX) < 0.5 && abs(screen.frame.minY) < 0.5
      } ?? screens.first

    return ScreenSnapshot(
      screens: screens,
      mainScreenTop: primaryScreen?.frame.maxY ?? 0
    )
  }
}
