import SwiftUI
import EventKit
import ServiceManagement

struct SettingsView: View {
    @ObservedObject private var calendarManager = CalendarManager.shared
    @ObservedObject private var settings = AppSettings.shared
    @State private var launchAtLogin = false

    private let timingOptions = [0, 1, 2, 5, 10, 15]

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if !calendarManager.accessGranted {
                permissionBanner
            }

            Form {
                Section("Calendars") {
                    if calendarManager.availableCalendars.isEmpty {
                        Text("No calendars available")
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(calendarManager.availableCalendars, id: \.calendarIdentifier) { calendar in
                            Toggle(isOn: binding(for: calendar)) {
                                HStack(spacing: 8) {
                                    Circle()
                                        .fill(Color(nsColor: calendar.color))
                                        .frame(width: 10, height: 10)
                                    Text(calendar.title)
                                }
                            }
                        }
                    }
                }

                Section("Timing") {
                    Picker("Remind me", selection: $settings.reminderMinutesBefore) {
                        ForEach(timingOptions, id: \.self) { minutes in
                            if minutes == 0 {
                                Text("At meeting time").tag(minutes)
                            } else {
                                Text("\(minutes) min before").tag(minutes)
                            }
                        }
                    }

                    Picker("Auto-dismiss after", selection: $settings.autoDismissSeconds) {
                        Text("30 seconds").tag(30)
                        Text("1 minute").tag(60)
                        Text("2 minutes").tag(120)
                        Text("5 minutes").tag(300)
                        Text("Never").tag(0)
                    }
                }

                Section("General") {
                    Toggle("Show reminders for all-day events", isOn: $settings.showForAllDayEvents)

                    Toggle("Launch at login", isOn: $launchAtLogin)
                        .onChange(of: launchAtLogin) { newValue in
                            setLaunchAtLogin(newValue)
                        }
                }
            }
            .formStyle(.grouped)
            .onChange(of: settings.selectedCalendarIDs) { _ in
                ReminderScheduler.shared.reschedule()
            }
            .onChange(of: settings.reminderMinutesBefore) { _ in
                ReminderScheduler.shared.reschedule()
            }
        }
        .frame(width: 400, height: 480)
        .onAppear {
            calendarManager.refreshCalendars()
            loadLaunchAtLoginState()
        }
    }

    private var permissionBanner: some View {
        HStack {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundStyle(.yellow)
            Text("Calendar access not granted. Open System Settings > Privacy & Security > Calendars.")
                .font(.caption)
            Spacer()
            Button("Open Settings") {
                NSWorkspace.shared.open(URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Calendars")!)
            }
            .buttonStyle(.bordered)
            .controlSize(.small)
        }
        .padding(12)
        .background(.yellow.opacity(0.1))
    }

    private func binding(for calendar: EKCalendar) -> Binding<Bool> {
        Binding(
            get: { settings.selectedCalendarIDs.contains(calendar.calendarIdentifier) },
            set: { isOn in
                if isOn {
                    settings.selectedCalendarIDs.insert(calendar.calendarIdentifier)
                } else {
                    settings.selectedCalendarIDs.remove(calendar.calendarIdentifier)
                }
            }
        )
    }

    private func setLaunchAtLogin(_ enabled: Bool) {
        if #available(macOS 13.0, *) {
            do {
                if enabled {
                    try SMAppService.mainApp.register()
                } else {
                    try SMAppService.mainApp.unregister()
                }
            } catch {
                launchAtLogin = !enabled
            }
        }
    }

    private func loadLaunchAtLoginState() {
        if #available(macOS 13.0, *) {
            launchAtLogin = SMAppService.mainApp.status == .enabled
        }
    }
}
