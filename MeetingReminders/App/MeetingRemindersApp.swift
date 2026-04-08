import SwiftUI

@main
struct MeetingRemindersApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        MenuBarExtra {
            MenuBarView()
        } label: {
            Image(systemName: "calendar.badge.clock")
        }
    }
}
