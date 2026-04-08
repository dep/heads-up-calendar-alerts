import SwiftUI

struct MenuBarView: View {
    @ObservedObject private var calendarManager = CalendarManager.shared

    var body: some View {
        let events = calendarManager.fetchUpcomingEvents(withinMinutes: 480)

        Text("Upcoming Meetings")
            .font(.headline)

        Divider()

        if events.isEmpty {
            Text("No upcoming meetings")
                .foregroundStyle(.secondary)
        } else {
            ForEach(events.prefix(5)) { event in
                eventRow(event)
            }
        }

        Divider()

        Button("Settings...") {
            SettingsWindowController.show()
        }
        .keyboardShortcut(",")

        Button("Quit Heads Up") {
            NSApplication.shared.terminate(nil)
        }
        .keyboardShortcut("q")
    }

    private func eventRow(_ event: CalendarEvent) -> some View {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        let timeStr = formatter.string(from: event.startDate)

        return HStack {
            Circle()
                .fill(Color(nsColor: event.calendarColor))
                .frame(width: 8, height: 8)
            Text("\(timeStr) - \(event.title)")
        }
    }
}
