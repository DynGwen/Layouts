import AppKit
import Combine

/// Hosts native materials while keeping drag hit testing independent of rendering.
final class LayoutOverlayView: NSView {
  private(set) var dropZones: [LayoutDropZone] = []
  private let targetContainer: NSView
  private let targetContent: NSView
  private let cards = LayoutAction.dropTargets.map { LayoutTargetCardView(action: $0) }
  private var accessibilityObserver: NSObjectProtocol?
  private var scaleSubscription: AnyCancellable?

  var hoveredAction: LayoutAction? {
    didSet {
      guard oldValue != hoveredAction else { return }
      for card in cards {
        card.isHovered = card.action == hoveredAction
      }
    }
  }

  override var isFlipped: Bool { true }

  override init(frame frameRect: NSRect) {
    let content = FlippedOverlayContentView(frame: .zero)
    targetContent = content

    if #available(macOS 26.0, *) {
      let container = NSGlassEffectContainerView(frame: .zero)
      // Batch the four materials without merging separate drop targets.
      container.spacing = 0
      container.contentView = content
      targetContainer = container
    } else {
      targetContainer = content
    }

    super.init(frame: frameRect)
    addSubview(targetContainer)
    cards.forEach { targetContent.addSubview($0) }
    refreshAccessibility()
    rebuildDropZones()

    accessibilityObserver = NSWorkspace.shared.notificationCenter.addObserver(
      forName: NSWorkspace.accessibilityDisplayOptionsDidChangeNotification,
      object: nil,
      queue: .main
    ) { [weak self] _ in
      self?.refreshAccessibility()
    }

    scaleSubscription = AppPreferences.shared.$centeredScale
      .removeDuplicates()
      .receive(on: RunLoop.main)
      .sink { [weak self] _ in
        self?.cards.forEach { $0.refreshPreview() }
      }

  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func layout() {
    super.layout()
    rebuildDropZones()
  }

  func action(at localPoint: CGPoint) -> LayoutAction? {
    dropZones.first(where: { $0.frame.contains(localPoint) })?.action
  }

  private func rebuildDropZones() {
    targetContainer.frame = bounds
    targetContent.frame = targetContainer.bounds
    dropZones = LayoutOverlayGeometry.dropZones(in: bounds)
    for (card, zone) in zip(cards, dropZones) {
      card.frame = zone.frame
    }
  }

  private func refreshAccessibility() {
    let workspace = NSWorkspace.shared
    for card in cards {
      card.updateAccessibility(
        reduceTransparency: workspace.accessibilityDisplayShouldReduceTransparency,
        increaseContrast: workspace.accessibilityDisplayShouldIncreaseContrast
      )
    }
  }

  deinit {
    if let accessibilityObserver {
      NSWorkspace.shared.notificationCenter.removeObserver(accessibilityObserver)
    }
  }
}

private final class FlippedOverlayContentView: NSView {
  override var isFlipped: Bool { true }
}
