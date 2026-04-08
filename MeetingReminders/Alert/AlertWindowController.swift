import Cocoa
import SwiftUI

final class AlertWindow: NSWindow {
    override var canBecomeKey: Bool { true }
    override var canBecomeMain: Bool { true }
}

enum AlertWindowController {
    private static var activeWindows: [AlertWindow] = []

    static func show(for event: CalendarEvent) {
        DispatchQueue.main.async {
            let screen = NSScreen.main ?? NSScreen.screens.first!
            let frame = screen.frame

            let window = AlertWindow(
                contentRect: frame,
                styleMask: [.borderless],
                backing: .buffered,
                defer: false
            )
            window.level = .screenSaver
            window.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
            window.isOpaque = false
            window.backgroundColor = .clear
            window.hasShadow = false

            let dismissAction = {
                window.orderOut(nil)
                activeWindows.removeAll { $0 === window }
            }

            window.contentView = NSHostingView(
                rootView: AlertView(event: event, onDismiss: dismissAction)
            )

            activeWindows.append(window)
            window.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
        }
    }
}
