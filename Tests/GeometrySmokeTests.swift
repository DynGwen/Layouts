import Foundation

private func approximatelyEqual(
  _ lhs: CGFloat,
  _ rhs: CGFloat,
  epsilon: CGFloat = 0.001
) -> Bool {
  abs(lhs - rhs) < epsilon
}

private func expectRect(
  _ actual: CGRect?,
  _ expected: CGRect,
  _ name: String
) {
  guard let actual else {
    fatalError("\(name): received nil")
  }

  guard
    approximatelyEqual(actual.minX, expected.minX),
    approximatelyEqual(actual.minY, expected.minY),
    approximatelyEqual(actual.width, expected.width),
    approximatelyEqual(actual.height, expected.height)
  else {
    fatalError("\(name): got \(actual), expected \(expected)")
  }
}

@main
enum GeometrySmokeTests {
  static func main() {
    let primary = ScreenGeometry(
      id: 1,
      frame: CGRect(x: 0, y: 0, width: 1000, height: 800),
      visibleFrame: CGRect(x: 0, y: 0, width: 1000, height: 800)
    )

    expectRect(
      LayoutEngine.frame(for: .full, screen: primary, margin: 10),
      CGRect(x: 10, y: 10, width: 980, height: 780),
      "Full"
    )
    expectRect(
      LayoutEngine.frame(for: .left, screen: primary, margin: 10),
      CGRect(x: 10, y: 10, width: 485, height: 780),
      "Left"
    )
    expectRect(
      LayoutEngine.frame(for: .right, screen: primary, margin: 10),
      CGRect(x: 505, y: 10, width: 485, height: 780),
      "Right"
    )
    expectRect(
      LayoutEngine.frame(
        for: .centered,
        screen: primary,
        margin: 10,
        centeredScale: 0.60
      ),
      CGRect(x: 206, y: 166, width: 588, height: 468),
      "Centered 60 percent"
    )

    guard
      let centered = LayoutEngine.frame(
        for: .centered,
        screen: primary,
        margin: 10,
        centeredScale: 0.60
      ),
      approximatelyEqual(centered.midX, primary.visibleFrame.midX),
      approximatelyEqual(centered.midY, primary.visibleFrame.midY)
    else {
      fatalError("Centered: frame is not centered on both axes")
    }

    let preview = LayoutEngine.centeredScaledFrame(
      in: CGRect(x: 10, y: 10, width: 100, height: 80),
      scale: 0.60
    )
    guard
      approximatelyEqual(preview.midX, 60),
      approximatelyEqual(preview.midY, 50),
      approximatelyEqual(preview.width, 60),
      approximatelyEqual(preview.height, 48)
    else {
      fatalError("Centered preview: miniature is not centered on both axes")
    }


    expectRect(
      LayoutEngine.frame(
        for: .centered,
        screen: primary,
        margin: 10,
        centeredScale: 0.75
      ),
      CGRect(x: 132.5, y: 107.5, width: 735, height: 585),
      "Centered 75 percent"
    )

    let constrainedCenteredOrigin = LayoutEngine.anchoredOrigin(
      for: .centered,
      targetFrame: CGRect(x: 206, y: 166, width: 588, height: 468),
      actualSize: CGSize(width: 600, height: 480)
    )
    guard
      approximatelyEqual(constrainedCenteredOrigin.x, 200),
      approximatelyEqual(constrainedCenteredOrigin.y, 160)
    else {
      fatalError("Centered: constrained size was not re-centered")
    }

    let original = CGRect(x: -100, y: 30, width: 500, height: 400)
    let accessibility = CoordinateConverter.appKitToAccessibility(
      original,
      mainScreenTop: 800
    )
    let roundTrip = CoordinateConverter.accessibilityToAppKit(
      accessibility,
      mainScreenTop: 800
    )
    expectRect(roundTrip, original, "Coordinate conversion")

    let secondary = ScreenGeometry(
      id: 2,
      frame: CGRect(x: 1000, y: 0, width: 1200, height: 900),
      visibleFrame: CGRect(x: 1000, y: 0, width: 1200, height: 860)
    )
    let resolved = ScreenResolver.screen(
      containing: CGRect(x: 1400, y: 100, width: 400, height: 400),
      from: [primary, secondary]
    )

    guard resolved?.frame == secondary.frame else {
      fatalError("ScreenResolver selected the wrong display")
    }

    let pointResolved = ScreenResolver.screen(
      containing: CGPoint(x: 1700, y: 450),
      from: [primary, secondary]
    )
    guard pointResolved?.id == secondary.id else {
      fatalError("Point-based ScreenResolver selected the wrong display")
    }

    testOverlayGeometry()
    testSettingsCentering()
    testMenuPlacement()
    print("Layouts geometry smoke tests passed (window layouts, overlay, settings centering)")
  }

  private static func testOverlayGeometry() {
    let bounds = CGRect(x: 0, y: 0, width: 126, height: 410)
    let zones = LayoutOverlayGeometry.dropZones(in: bounds)
    guard zones.map(\.action) == LayoutAction.dropTargets else {
      fatalError("Overlay: target order changed")
    }
    for (index, zone) in zones.enumerated() {
      expectRect(
        zone.frame,
        CGRect(x: 10, y: 10 + CGFloat(index) * 100, width: 106, height: 90),
        "Overlay target \(index)"
      )
      guard bounds.contains(zone.frame) else {
        fatalError("Overlay: a target is outside the panel")
      }
      for other in zones.dropFirst(index + 1) {
        guard !zone.frame.intersects(other.frame) else {
          fatalError("Overlay: drop targets overlap")
        }
      }
    }

    // Negative display coordinates, menu bar/Dock insets, and a short screen.
    for visible in [
      CGRect(x: -1440, y: 40, width: 1440, height: 836),
      CGRect(x: 120, y: -300, width: 280, height: 220)
    ] {
      let screen = ScreenGeometry(id: 3, frame: visible, visibleFrame: visible)
      let panel = LayoutOverlayGeometry.panelFrame(on: screen)
      guard visible.contains(panel), approximatelyEqual(panel.midY, visible.midY) else {
        fatalError("Overlay: panel is not centered within the usable display")
      }
      let localBounds = CGRect(origin: .zero, size: panel.size)
      let compactZones = LayoutOverlayGeometry.dropZones(in: localBounds)
      guard compactZones.count == 4,
        compactZones.allSatisfy({ localBounds.contains($0.frame) && $0.frame.height > 0 })
      else {
        fatalError("Overlay: compact targets do not fit the panel")
      }
    }
    guard LayoutOverlayGeometry.dropZones(in: .zero).isEmpty else {
      fatalError("Overlay: empty bounds should have no targets")
    }
  }

  private static func testSettingsCentering() {
    // Match the placement used every time SettingsWindowController.show() runs.
    let usable = CGRect(x: -1920, y: 48, width: 1920, height: 1008)
    for size in [CGSize(width: 440, height: 162), CGSize(width: 600, height: 240)] {
      let origin = LayoutEngine.anchoredOrigin(
        for: .centered, targetFrame: usable, actualSize: size
      )
      let frame = CGRect(origin: origin, size: size)
      guard approximatelyEqual(frame.midX, usable.midX),
        approximatelyEqual(frame.midY, usable.midY)
      else {
        fatalError("Settings: window is not geometrically centered on both axes")
      }
    }
  }

  private static func testMenuPlacement() {
    let visible = CGRect(x: -1440, y: 40, width: 1440, height: 836)
    let size = CGSize(width: 340, height: 420)
    let positions: [CGFloat] = [-1430, -720, -10]
    for x in positions {
      let anchor = CGRect(x: x - 10, y: visible.maxY, width: 20, height: 24)
      let frame = MenuPanelGeometry.frame(for: size, anchoredTo: anchor, in: visible)
      guard visible.insetBy(dx: 8, dy: 8).contains(frame), frame.maxY <= anchor.minY - 8 else {
        fatalError("Menu: panel extends outside the usable display or overlaps its anchor")
      }
      if x == -720, !approximatelyEqual(frame.midX, anchor.midX) {
        fatalError("Menu: panel is not aligned with its status item")
      }
    }
  }
}
