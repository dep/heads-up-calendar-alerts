import EventKit
import Foundation

enum ZoomURLExtractor {
    private static let pattern = #"https?://[\w.-]*zoom\.us/[jw]/\d+(\?[^\s\"<>)}\]]*)?"#

    static func extractURL(from event: EKEvent) -> URL? {
        if let url = event.url, isZoomURL(url) {
            return url
        }

        if let location = event.location, let url = findZoomURL(in: location) {
            return url
        }

        if let notes = event.notes, let url = findZoomURL(in: notes) {
            return url
        }

        return nil
    }

    private static func isZoomURL(_ url: URL) -> Bool {
        guard let host = url.host?.lowercased() else { return false }
        return host.hasSuffix("zoom.us")
    }

    private static func findZoomURL(in text: String) -> URL? {
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
