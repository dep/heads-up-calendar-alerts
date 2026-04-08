# Heads Up

A macOS menu bar app that alerts you before upcoming calendar events.

## Features

- Menu bar icon showing your next 5 upcoming meetings
- Full-screen alert before each event with title, calendar, location, and countdown
- One-click Zoom join — detects Zoom URLs from event links, location, or notes
- Snooze alerts until the meeting starts
- Configurable reminder lead time and auto-dismiss delay
- Choose which calendars to monitor
- Keyboard shortcuts: Enter to join Zoom, Escape to dismiss

## Requirements

- macOS 13.0+
- Calendar access permission

## Build

Requires Xcode 16+ and Swift 5.9.

```
xcodebuild -project HeadsUp.xcodeproj -scheme HeadsUp -configuration Debug build
```

The project uses [XcodeGen](https://github.com/yonaskolb/xcodegen) — regenerate the Xcode project from `project.yml` if needed:

```
xcodegen generate
```

## Distribution

- **Bundle ID**: `com.dnnypck.HeadsUp`
- **Team ID**: `299R8V27FZ`
- **Category**: Productivity
- Archive via Xcode (Product → Archive) and upload to App Store Connect.

## Tech Stack

- SwiftUI
- EventKit (native macOS Calendar API)
- No external dependencies
