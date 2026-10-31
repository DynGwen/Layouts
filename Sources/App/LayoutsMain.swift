import AppKit

#if compiler(<6.4)
#error("Layouts requires Swift 6.4 or later with the macOS 27 SDK.")
#endif

@main
enum LayoutsMain {
  static func main() {
    let app = NSApplication.shared
    let delegate = AppDelegate()
    app.delegate = delegate
    app.run()
  }
}
