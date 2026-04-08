import SwiftUI

struct MenuBarIcon: View {
    var body: some View {
        Image(nsImage: makeIcon())
    }

    private func makeIcon() -> NSImage {
        let config = NSImage.SymbolConfiguration(pointSize: 13, weight: .regular)
        let image = NSImage(systemSymbolName: "bell.badge", accessibilityDescription: "Heads Up")!
            .withSymbolConfiguration(config)!
        image.isTemplate = true
        image.size = NSSize(width: 18, height: 18)
        return image
    }
}
