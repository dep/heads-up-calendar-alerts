import Foundation

final class AppSettings: ObservableObject {
    static let shared = AppSettings()

    @Published var reminderMinutesBefore: Int {
        didSet { UserDefaults.standard.set(reminderMinutesBefore, forKey: "reminderMinutesBefore") }
    }

    @Published var autoDismissSeconds: Int {
        didSet { UserDefaults.standard.set(autoDismissSeconds, forKey: "autoDismissSeconds") }
    }

    @Published var showForAllDayEvents: Bool {
        didSet { UserDefaults.standard.set(showForAllDayEvents, forKey: "showForAllDayEvents") }
    }

    @Published var selectedCalendarIDs: Set<String> {
        didSet {
            let data = try? JSONEncoder().encode(Array(selectedCalendarIDs))
            UserDefaults.standard.set(data, forKey: "selectedCalendarIDs")
        }
    }

    private init() {
        let defaults = UserDefaults.standard

        if defaults.object(forKey: "reminderMinutesBefore") != nil {
            reminderMinutesBefore = defaults.integer(forKey: "reminderMinutesBefore")
        } else {
            reminderMinutesBefore = 1
        }

        if defaults.object(forKey: "autoDismissSeconds") != nil {
            autoDismissSeconds = defaults.integer(forKey: "autoDismissSeconds")
        } else {
            autoDismissSeconds = 60
        }

        showForAllDayEvents = defaults.bool(forKey: "showForAllDayEvents")

        if let data = defaults.data(forKey: "selectedCalendarIDs"),
           let ids = try? JSONDecoder().decode([String].self, from: data) {
            selectedCalendarIDs = Set(ids)
        } else {
            selectedCalendarIDs = []
        }
    }
}
