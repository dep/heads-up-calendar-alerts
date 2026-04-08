import Cocoa
import EventKit

final class CalendarManager: ObservableObject {
    static let shared = CalendarManager()

    private let eventStore = EKEventStore()

    @Published var accessGranted = false
    @Published var availableCalendars: [EKCalendar] = []

    private init() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(storeChanged),
            name: .EKEventStoreChanged,
            object: eventStore
        )
    }

    func requestAccess() async {
        do {
            let granted: Bool
            if #available(macOS 14.0, *) {
                granted = try await eventStore.requestFullAccessToEvents()
            } else {
                granted = try await eventStore.requestAccess(to: .event)
            }
            await MainActor.run {
                self.accessGranted = granted
                if granted {
                    self.refreshCalendars()
                }
            }
        } catch {
            await MainActor.run {
                self.accessGranted = false
            }
        }
    }

    func refreshCalendars() {
        availableCalendars = eventStore.calendars(for: .event)
            .sorted { $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedAscending }
    }

    func fetchUpcomingEvents(withinMinutes minutes: Int = 1440) -> [CalendarEvent] {
        guard accessGranted else { return [] }

        let selectedIDs = AppSettings.shared.selectedCalendarIDs
        let calendars: [EKCalendar]?

        if selectedIDs.isEmpty {
            calendars = nil
        } else {
            calendars = eventStore.calendars(for: .event).filter { selectedIDs.contains($0.calendarIdentifier) }
            if calendars?.isEmpty == true { return [] }
        }

        let start = Date()
        let end = Calendar.current.date(byAdding: .minute, value: minutes, to: start)!
        let predicate = eventStore.predicateForEvents(withStart: start, end: end, calendars: calendars)
        let ekEvents = eventStore.events(matching: predicate)

        return ekEvents
            .filter { AppSettings.shared.showForAllDayEvents || !$0.isAllDay }
            .map { CalendarEvent(from: $0) }
            .sorted { $0.startDate < $1.startDate }
    }

    @objc private func storeChanged() {
        DispatchQueue.main.async {
            self.refreshCalendars()
            ReminderScheduler.shared.reschedule()
        }
    }
}
