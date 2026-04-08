import Foundation

final class ReminderScheduler: ObservableObject {
    static let shared = ReminderScheduler()

    @Published var nextAlertEvent: CalendarEvent?

    private var alertTimer: Timer?
    private var refreshTimer: Timer?
    private var alertedEventIDs: Set<String> = []

    private init() {}

    func start() {
        scheduleNextAlert()
        refreshTimer = Timer.scheduledTimer(withTimeInterval: 900, repeats: true) { [weak self] _ in
            self?.reschedule()
        }
    }

    func stop() {
        alertTimer?.invalidate()
        alertTimer = nil
        refreshTimer?.invalidate()
        refreshTimer = nil
    }

    func reschedule() {
        cleanupExpiredEvents()
        scheduleNextAlert()
    }

    private func scheduleNextAlert() {
        alertTimer?.invalidate()
        alertTimer = nil

        guard let (event, alertTime) = computeNextAlert() else {
            nextAlertEvent = nil
            return
        }

        nextAlertEvent = event

        let delay = alertTime.timeIntervalSinceNow
        if delay <= 0 {
            fireAlert(for: event)
            return
        }

        alertTimer = Timer.scheduledTimer(withTimeInterval: delay, repeats: false) { [weak self] _ in
            self?.fireAlert(for: event)
        }
    }

    private func computeNextAlert() -> (CalendarEvent, Date)? {
        let events = CalendarManager.shared.fetchUpcomingEvents(withinMinutes: 1440)
        let leadTime = TimeInterval(AppSettings.shared.reminderMinutesBefore * 60)

        var best: (CalendarEvent, Date)?
        for event in events {
            guard !alertedEventIDs.contains(event.id) else { continue }

            let alertTime = event.startDate.addingTimeInterval(-leadTime)

            if best == nil || alertTime < best!.1 {
                best = (event, alertTime)
            }
        }
        return best
    }

    private func fireAlert(for event: CalendarEvent) {
        alertedEventIDs.insert(event.id)
        AlertWindowController.show(for: event)
        scheduleNextAlert()
    }

    private func cleanupExpiredEvents() {
        let now = Date()
        let currentEvents = CalendarManager.shared.fetchUpcomingEvents(withinMinutes: 0)
        let activeIDs = Set(currentEvents.map(\.id))
        alertedEventIDs = alertedEventIDs.filter { activeIDs.contains($0) }

        // Also remove IDs that are clearly old (not in any upcoming window)
        if alertedEventIDs.count > 100 {
            alertedEventIDs.removeAll()
        }
    }
}
