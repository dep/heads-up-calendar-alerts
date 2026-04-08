import SwiftUI

struct AlertView: View {
    let event: CalendarEvent
    let onDismiss: () -> Void
    let onSnooze: () -> Void

    @State private var appeared = false
    @State private var autoDismissTimer: Timer?

    var body: some View {
        ZStack {
            Color.black.opacity(0.75)
                .ignoresSafeArea()
                .onTapGesture { dismiss() }

            VStack(spacing: 24) {
                Image(systemName: "calendar.badge.exclamationmark")
                    .font(.system(size: 48))
                    .foregroundStyle(.white)

                Text(event.title)
                    .font(.system(size: 32, weight: .bold))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                    .lineLimit(3)

                Text(timeDescription)
                    .font(.system(size: 20, weight: .medium))
                    .foregroundStyle(.white.opacity(0.9))

                HStack(spacing: 6) {
                    Circle()
                        .fill(Color(nsColor: event.calendarColor))
                        .frame(width: 10, height: 10)
                    Text(event.calendarTitle)
                        .font(.system(size: 15))
                        .foregroundStyle(.white.opacity(0.7))
                }

                if let location = event.location, !location.isEmpty,
                   event.zoomURL == nil {
                    Text(location)
                        .font(.system(size: 14))
                        .foregroundStyle(.white.opacity(0.6))
                        .lineLimit(2)
                }

                HStack(spacing: 16) {
                    if let zoomURL = event.zoomURL {
                        Button(action: { joinZoom(zoomURL) }) {
                            Label("Join Zoom", systemImage: "video.fill")
                                .font(.system(size: 16, weight: .semibold))
                                .padding(.horizontal, 24)
                                .padding(.vertical, 12)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.blue)
                        .keyboardShortcut(.return, modifiers: [])
                    }

                    if event.startDate.timeIntervalSinceNow > 5 {
                        Button(action: { snooze() }) {
                            Label("Snooze until event starts", systemImage: "clock.arrow.circlepath")
                                .font(.system(size: 16, weight: .medium))
                                .padding(.horizontal, 24)
                                .padding(.vertical, 12)
                        }
                        .buttonStyle(.bordered)
                        .tint(.orange)
                        .keyboardShortcut("s", modifiers: [])
                    }

                    Button(action: { dismiss() }) {
                        Text("Dismiss")
                            .font(.system(size: 16, weight: .medium))
                            .padding(.horizontal, 24)
                            .padding(.vertical, 12)
                    }
                    .buttonStyle(.bordered)
                    .tint(.white.opacity(0.3))
                    .keyboardShortcut(.escape, modifiers: [])
                }
                .padding(.top, 8)
            }
            .padding(48)
            .frame(maxWidth: 520)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20))
            .scaleEffect(appeared ? 1.0 : 0.8)
            .opacity(appeared ? 1.0 : 0)
        }
        .onAppear {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                appeared = true
            }
            startAutoDismiss()
        }
        .onDisappear {
            autoDismissTimer?.invalidate()
        }
    }

    private var timeDescription: String {
        let minutesUntil = event.startDate.timeIntervalSinceNow / 60
        if minutesUntil <= 0 {
            return "Starting now"
        } else if minutesUntil < 1 {
            return "Starting in less than a minute"
        } else {
            let mins = Int(ceil(minutesUntil))
            return "Starting in \(mins) minute\(mins == 1 ? "" : "s")"
        }
    }

    private func joinZoom(_ url: URL) {
        NSWorkspace.shared.open(url)
        dismiss()
    }

    private func snooze() {
        autoDismissTimer?.invalidate()
        withAnimation(.easeOut(duration: 0.2)) {
            appeared = false
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            onSnooze()
        }
    }

    private func dismiss() {
        autoDismissTimer?.invalidate()
        withAnimation(.easeOut(duration: 0.2)) {
            appeared = false
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            onDismiss()
        }
    }

    private func startAutoDismiss() {
        let seconds = TimeInterval(AppSettings.shared.autoDismissSeconds)
        guard seconds > 0 else { return }
        autoDismissTimer = Timer.scheduledTimer(withTimeInterval: seconds, repeats: false) { _ in
            dismiss()
        }
    }
}
