import SwiftUI

@main
struct HeadsUpApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        MenuBarExtra {
            MenuBarView()
        } label: {
            MenuBarIcon()
        }
    }
}
