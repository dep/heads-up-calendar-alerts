import EventKit
import Foundation

enum ConferenceURLExtractor {
    private struct Provider {
        let pattern: String
        let host: String
    }

    private static let zoom = Provider(
        pattern: #"https?://[\w.-]*zoom\.us/[jw]/\d+(\?[^\s\"<>)}\]]*)?"#,
        host: "zoom.us"
    )

    private static let meet = Provider(
        pattern: #"https?://meet\.google\.com/[a-z0-9\-]+(\?[^\s\"<>)}\]]*)?"#,
        host: "meet.google.com"
    )

    static func zoomURL(from event: EKEvent) -> URL? {
        extractURL(from: event, provider: zoom)
    }

    static func meetURL(from event: EKEvent) -> URL? {
        extractURL(from: event, provider: meet)
    }

    private static func extractURL(from event: EKEvent, provider: Provider) -> URL? {
        if let url = event.url, matchesHost(url, provider: provider) {
            return url
        }

        for text in [event.location, event.notes] {
            if let text, let url = findURL(in: text, pattern: provider.pattern) {
                return url
            }
        }

        return nil
    }

    private static func matchesHost(_ url: URL, provider: Provider) -> Bool {
        guard let host = url.host?.lowercased() else { return false }
        return host == provider.host || host.hasSuffix("." + provider.host)
    }

    private static func findURL(in text: String, pattern: String) -> URL? {
        guard let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive) else {
            return nil
        }
        let range = NSRange(text.startIndex..., in: text)
        guard let match = regex.firstMatch(in: text, range: range),
              let matchRange = Range(match.range, in: text) else {
            return nil
        }
        return URL(string: String(text[matchRange]))
    }
}
