import AppKit
import SwiftUI

@MainActor
class WindowPositionManager {
  private let window: NSWindow
  private let userSettings: UserSettings

  init(window: NSWindow, userSettings: UserSettings) {
    self.window = window
    self.userSettings = userSettings
  }

  func updateWindowPosition() {
    let frameOrigin = windowFrameOrigin(window)
    window.setFrameOrigin(frameOrigin)
  }

  private func windowFrameOrigin(_ window: NSWindow) -> CGPoint {
    var origin = NSPoint.zero

    if let mainScreen = NSScreen.main {
      //
      // Determine screen
      //

      var screen = mainScreen
      if let widgetScreen = WidgetScreen(rawValue: userSettings.widgetScreen) {
        NSScreen.screens.forEach { s in
          //
          // +--------------------+--------------------+--------------------+
          // |                    |                    |                    |
          // |                    |                    |                    |
          // |                    |                    |                    |
          // |(-100,100)          |(0,100)             |(100,100)           |
          // +--------------------+--------------------+--------------------+
          // |                    |                    |                    |
          // |                    |        main        |                    |
          // |                    |                    |                    |
          // |(-100,0)            |(0,0)               |(100,0)             |
          // +--------------------+--------------------+--------------------+
          // |                    |                    |                    |
          // |                    |                    |                    |
          // |                    |                    |                    |
          // |(-100,-100)         |(0,-100)            |(100,-100)          |
          // +--------------------+--------------------+--------------------+
          //

          switch widgetScreen {
          case WidgetScreen.primary:
            if s.frame.origin == NSPoint.zero {
              screen = s
            }
          case WidgetScreen.bottomLeft:
            if s.frame.origin.x <= screen.frame.origin.x,
              s.frame.origin.y <= screen.frame.origin.y
            {
              screen = s
            }
          case WidgetScreen.bottomRight:
            if s.frame.origin.x >= screen.frame.origin.x,
              s.frame.origin.y <= screen.frame.origin.y
            {
              screen = s
            }
          case WidgetScreen.topLeft:
            if s.frame.origin.x <= screen.frame.origin.x,
              s.frame.origin.y >= screen.frame.origin.y
            {
              screen = s
            }
          case WidgetScreen.topRight:
            if s.frame.origin.x >= screen.frame.origin.x,
              s.frame.origin.y >= screen.frame.origin.y
            {
              screen = s
            }
          case WidgetScreen.leftTop:
            // Leftmost screen (top)
            if s.frame.origin.x < screen.frame.origin.x {
              screen = s
            } else if s.frame.origin.x == screen.frame.origin.x {
              if s.frame.origin.y > screen.frame.origin.y {
                screen = s
              }
            }
          case WidgetScreen.leftBottom:
            // Leftmost screen (bottom)
            if s.frame.origin.x < screen.frame.origin.x {
              screen = s
            } else if s.frame.origin.x == screen.frame.origin.x {
              if s.frame.origin.y < screen.frame.origin.y {
                screen = s
              }
            }
          case WidgetScreen.rightTop:
            // Rightmost screen (top)
            if s.frame.origin.x > screen.frame.origin.x {
              screen = s
            } else if s.frame.origin.x == screen.frame.origin.x {
              if s.frame.origin.y > screen.frame.origin.y {
                screen = s
              }
            }
          case WidgetScreen.rightBottom:
            // Rightmost screen (bottom)
            if s.frame.origin.x > screen.frame.origin.x {
              screen = s
            } else if s.frame.origin.x == screen.frame.origin.x {
              if s.frame.origin.y < screen.frame.origin.y {
                screen = s
              }
            }
          }
        }
      }

      //
      // Determine origin
      //

      let screenFrame = userSettings.widgetAllowOverlappingWithDock ? screen.frame : screen.visibleFrame
      if let widgetPosition = WidgetPosition(rawValue: userSettings.widgetPosition) {
        switch widgetPosition {
        case WidgetPosition.bottomLeft:
          origin.x = screenFrame.origin.x + 10
          origin.y = screenFrame.origin.y + 10

        case WidgetPosition.topLeft:
          origin.x = screenFrame.origin.x + 10
          origin.y = screenFrame.origin.y + screenFrame.size.height - window.frame.height - 10

        case WidgetPosition.topRight:
          origin.x = screenFrame.origin.x + screenFrame.size.width - window.frame.width - 10
          origin.y = screenFrame.origin.y + screenFrame.size.height - window.frame.height - 10

        default:
          // WidgetPosition.bottomRight
          origin.x = screenFrame.origin.x + screenFrame.size.width - window.frame.width - 10
          origin.y = screenFrame.origin.y + 10
        }
      }
    }

    return origin
  }
}
