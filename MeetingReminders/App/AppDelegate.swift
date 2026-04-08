import Cocoa
import EventKit

final class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        Task {
            await CalendarManager.shared.requestAccess()
            await MainActor.run {
                ReminderScheduler.shared.start()
            }
        }

        NSWorkspace.shared.notificationCenter.addObserver(
            self,
            selector: #selector(handleWake),
            name: NSWorkspace.didWakeNotification,
            object: nil
        )
    }

    func applicationWillTerminate(_ notification: Notification) {
        ReminderScheduler.shared.stop()
    }

    @objc private func handleWake() {
        ReminderScheduler.shared.reschedule()
    }
}
