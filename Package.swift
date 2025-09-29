// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "BigNotify",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(
            name: "BigNotify",
            targets: ["BigNotify"]
        )
    ],
    targets: [
        .executableTarget(
            name: "BigNotify",
            path: ".",
            sources: [
                "BigNotifyApp.swift",
                "ContentView.swift",
                "MeetingAlertView.swift",
                "AlertManager.swift",
                "CalendarManager.swift",
                "SettingsManager.swift"
            ]
        )
    ]
)
