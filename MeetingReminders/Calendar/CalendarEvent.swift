import Cocoa
import EventKit

struct CalendarEvent: Identifiable, Equatable {
    let id: String
    let title: String
    let startDate: Date
    let endDate: Date
    let location: String?
    let notes: String?
    let url: URL?
    let calendarTitle: String
    let calendarColor: NSColor
    let isAllDay: Bool
    var zoomURL: URL?

    init(from ekEvent: EKEvent) {
        id = ekEvent.eventIdentifier
        title = ekEvent.title ?? "Untitled"
        startDate = ekEvent.startDate
        endDate = ekEvent.endDate
        location = ekEvent.location
        notes = ekEvent.notes
        url = ekEvent.url
        calendarTitle = ekEvent.calendar.title
        calendarColor = ekEvent.calendar.color
        isAllDay = ekEvent.isAllDay
        zoomURL = ZoomURLExtractor.extractURL(from: ekEvent)
    }

    static func == (lhs: CalendarEvent, rhs: CalendarEvent) -> Bool {
        lhs.id == rhs.id && lhs.startDate == rhs.startDate
    }
}
