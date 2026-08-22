import ApplicationServices
import Foundation

struct AccessibilityClient {
  struct WindowHandle {
    let pid: pid_t
    let element: AXUIElement

    var identity: WindowIdentity {
      WindowIdentity(pid: pid, elementHash: CFHash(element))
    }
  }

  struct WindowIdentity: Hashable {
    let pid: pid_t
    let elementHash: CFHashCode
  }

  func focusedWindow(for pid: pid_t) -> WindowHandle? {
    let application = AXUIElementCreateApplication(pid)
    guard
      let window = copyElement(
        from: application,
        attribute: kAXFocusedWindowAttribute as CFString
      )
    else {
      return nil
    }

    return WindowHandle(pid: pid, element: window)
  }

  func frame(of window: WindowHandle) -> CGRect? {
    guard
      let positionValue = copyValue(
        from: window.element,
        attribute: kAXPositionAttribute as CFString
      ),
      let sizeValue = copyValue(
        from: window.element,
        attribute: kAXSizeAttribute as CFString
      ),
      CFGetTypeID(positionValue) == AXValueGetTypeID(),
      CFGetTypeID(sizeValue) == AXValueGetTypeID()
    else {
      return nil
    }

    var position = CGPoint.zero
    var size = CGSize.zero

    guard
      AXValueGetValue(
        positionValue as! AXValue,
        .cgPoint,
        &position
      ),
      AXValueGetValue(
        sizeValue as! AXValue,
        .cgSize,
        &size
      )
    else {
      return nil
    }

    return CGRect(origin: position, size: size)
  }

  @discardableResult
  func setFrame(
    _ frame: CGRect,
    of window: WindowHandle
  ) -> Bool {
    var position = frame.origin
    var size = frame.size

    guard
      let positionValue = AXValueCreate(.cgPoint, &position),
      let sizeValue = AXValueCreate(.cgSize, &size)
    else {
      return false
    }

    // Some applications constrain the first resize or move. Applying both
    // values twice makes the final frame deterministic without animation.
    let sizeResult1 = AXUIElementSetAttributeValue(
      window.element,
      kAXSizeAttribute as CFString,
      sizeValue
    )
    let positionResult1 = AXUIElementSetAttributeValue(
      window.element,
      kAXPositionAttribute as CFString,
      positionValue
    )
    let sizeResult2 = AXUIElementSetAttributeValue(
      window.element,
      kAXSizeAttribute as CFString,
      sizeValue
    )
    let positionResult2 = AXUIElementSetAttributeValue(
      window.element,
      kAXPositionAttribute as CFString,
      positionValue
    )

    return [sizeResult1, positionResult1, sizeResult2, positionResult2]
      .contains(.success)
  }

  @discardableResult
  func setPosition(
    _ position: CGPoint,
    of window: WindowHandle
  ) -> Bool {
    var mutablePosition = position
    guard let positionValue = AXValueCreate(.cgPoint, &mutablePosition) else {
      return false
    }

    return AXUIElementSetAttributeValue(
      window.element,
      kAXPositionAttribute as CFString,
      positionValue
    ) == .success
  }

  private func copyElement(
    from element: AXUIElement,
    attribute: CFString
  ) -> AXUIElement? {
    guard let value = copyValue(from: element, attribute: attribute) else {
      return nil
    }

    guard CFGetTypeID(value) == AXUIElementGetTypeID() else {
      return nil
    }

    return (value as! AXUIElement)
  }

  private func copyValue(
    from element: AXUIElement,
    attribute: CFString
  ) -> CFTypeRef? {
    var value: CFTypeRef?
    let error = AXUIElementCopyAttributeValue(
      element,
      attribute,
      &value
    )

    guard error == .success else {
      return nil
    }

    return value
  }
}
