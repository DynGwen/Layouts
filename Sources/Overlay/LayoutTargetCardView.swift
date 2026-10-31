import AppKit

/// A native glass surface with a light-gray layout preview.
final class LayoutTargetCardView: NSView {
  let action: LayoutAction
  private let preview: LayoutTargetPreviewView
  private var surface: NSView?
  private var reducedTransparency: Bool?

  var isHovered = false {
    didSet { preview.isHovered = isHovered }
  }

  init(action: LayoutAction) {
    self.action = action
    preview = LayoutTargetPreviewView(action: action)
    super.init(frame: .zero)
    setAccessibilityElement(true)
    setAccessibilityRole(.image)
    setAccessibilityLabel(action.displayName(in: AppPreferences.shared.language))
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func layout() {
    super.layout()
    surface?.frame = bounds
  }

  func refreshPreview() {
    setAccessibilityLabel(action.displayName(in: AppPreferences.shared.language))
    preview.needsDisplay = true
  }

  func updateAccessibility(reduceTransparency: Bool, increaseContrast: Bool) {
    preview.increaseContrast = increaseContrast
    guard reducedTransparency != reduceTransparency else { return }
    reducedTransparency = reduceTransparency

    if #available(macOS 26.0, *), let glass = surface as? NSGlassEffectView {
      glass.contentView = nil
    }
    preview.removeFromSuperview()
    surface?.removeFromSuperview()

    let background: NSView
    if reduceTransparency {
      let solid = SolidTargetBackgroundView(frame: bounds)
      solid.addSubview(preview)
      background = solid
    } else if #available(macOS 26.0, *) {
      let glass = NSGlassEffectView(frame: bounds)
      glass.style = .regular
      glass.cornerRadius = 15
      // The non-activating overlay must pass all input to the dragged window.
      // Hover feedback is drawn from global mouse events, rather than clicks.
      if #available(macOS 27.0, *) {
        glass.effectIsInteractive = false
      }
      glass.contentView = preview
      background = glass
    } else {
      let material = NSVisualEffectView(frame: bounds)
      material.material = .popover
      material.blendingMode = .behindWindow
      material.state = .active
      material.wantsLayer = true
      material.layer?.cornerRadius = 15
      material.layer?.masksToBounds = true
      material.addSubview(preview)
      background = material
    }

    preview.frame = background.bounds
    preview.autoresizingMask = [.width, .height]
    background.autoresizingMask = [.width, .height]
    addSubview(background)
    surface = background
  }
}

private final class SolidTargetBackgroundView: NSView {
  override func draw(_ dirtyRect: NSRect) {
    NSColor.windowBackgroundColor.setFill()
    NSBezierPath(roundedRect: bounds, xRadius: 15, yRadius: 15).fill()
  }

  override func viewDidChangeEffectiveAppearance() {
    super.viewDidChangeEffectiveAppearance()
    needsDisplay = true
  }
}

private final class LayoutTargetPreviewView: NSView {
  private let action: LayoutAction
  private let diagramColor = NSColor(srgbRed: 0.8, green: 0.8, blue: 0.8, alpha: 1)
  var isHovered = false { didSet { needsDisplay = true } }
  var increaseContrast = false { didSet { needsDisplay = true } }

  override var isFlipped: Bool { true }
  // Keep the diagram's light gray stable over glass and visual-effect materials.
  override var allowsVibrancy: Bool { false }

  init(action: LayoutAction) {
    self.action = action
    super.init(frame: .zero)
    setAccessibilityElement(false)
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidChangeEffectiveAppearance() {
    super.viewDidChangeEffectiveAppearance()
    needsDisplay = true
  }

  override func draw(_ dirtyRect: NSRect) {
    super.draw(dirtyRect)
    guard bounds.width > 36, bounds.height > 24 else { return }

    let outline = NSBezierPath(
      roundedRect: bounds.insetBy(dx: 1.5, dy: 1.5), xRadius: 14, yRadius: 14
    )
    let borderColor: NSColor = isHovered
      ? .controlAccentColor
      : (increaseContrast ? .labelColor : .separatorColor)
    borderColor.setStroke()
    outline.lineWidth = isHovered || increaseContrast ? 2 : 1
    outline.stroke()

    let showsLabel = bounds.height >= 64
    let miniature = CGRect(
      x: 18, y: showsLabel ? 12 : 10,
      width: bounds.width - 36, height: bounds.height - (showsLabel ? 40 : 20)
    )
    let screenPath = NSBezierPath(roundedRect: miniature, xRadius: 5, yRadius: 5)
    diagramColor.setStroke()
    screenPath.lineWidth = increaseContrast ? 1.5 : 1
    screenPath.stroke()

    let content = miniature.insetBy(dx: 4, dy: 4)
    if content.width > 0, content.height > 0 {
      let target: CGRect
      switch action {
      case .full:
        target = content
      case .left:
        target = CGRect(
          x: content.minX, y: content.minY,
          width: content.width * 0.48, height: content.height
        )
      case .right:
        target = CGRect(
          x: content.maxX - content.width * 0.48, y: content.minY,
          width: content.width * 0.48, height: content.height
        )
      case .centered:
        target = LayoutEngine.centeredScaledFrame(
          in: content, scale: CGFloat(AppPreferences.shared.centeredScale)
        )
      }
      let fillColor = isHovered
        ? NSColor.controlAccentColor
        : diagramColor
      fillColor.setFill()
      NSBezierPath(roundedRect: target, xRadius: 3, yRadius: 3).fill()
    }

    guard showsLabel else { return }
    let paragraph = NSMutableParagraphStyle()
    paragraph.alignment = .center
    paragraph.lineBreakMode = .byTruncatingTail
    (action.displayName(in: AppPreferences.shared.language) as NSString).draw(
      in: CGRect(x: 6, y: bounds.height - 22, width: bounds.width - 12, height: 16),
      withAttributes: [
        .font: NSFont.systemFont(ofSize: 11, weight: isHovered ? .semibold : .medium),
        .foregroundColor: NSColor.labelColor,
        .paragraphStyle: paragraph
      ]
    )
  }
}
