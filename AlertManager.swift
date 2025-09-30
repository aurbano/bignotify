import SwiftUI
import Combine

class AlertManager: ObservableObject {
    @Published var isShowingAlert = false
    @Published var meetingTitle = "Team Standup"
    @Published var meetingTime = "Starting Now"
    @Published var meetingLocation = "Zoom"
    @Published var meetingLink: String?

    private var alertWindow: NSPanel?
    private var dismissTimer: DispatchWorkItem?

    func showAlert(title: String = "Team Meeting", time: String = "Starting Now", location: String = "", meetingLink: String? = nil) {
        meetingTitle = title
        meetingTime = time
        meetingLocation = location
        self.meetingLink = meetingLink
        isShowingAlert = true

        if NSScreen.main != nil {
            // Dismiss any existing alert first
            if alertWindow != nil {
                dismissAlert()
            }

            let panel = NSPanel(
                contentRect: NSRect(x: 0, y: 0, width: 600, height: 400),
                styleMask: [.borderless, .nonactivatingPanel, .hudWindow],
                backing: .buffered,
                defer: false
            )

            panel.level = .modalPanel
            panel.isOpaque = false
            panel.backgroundColor = .clear
            panel.hasShadow = true
            panel.center()
            panel.isMovableByWindowBackground = true
            panel.collectionBehavior = [.canJoinAllSpaces, .transient, .ignoresCycle]
            panel.isFloatingPanel = true
            panel.becomesKeyOnlyIfNeeded = true

            let hostingView = NSHostingView(
                rootView: MeetingAlertView()
                    .environmentObject(self)
            )

            panel.contentView = hostingView
            panel.orderFrontRegardless()

            // Store reference to window
            alertWindow = panel

            // Auto-dismiss after 30 seconds
            dismissTimer?.cancel()
            let timer = DispatchWorkItem { [weak self] in
                self?.dismissAlert()
            }
            dismissTimer = timer
            DispatchQueue.main.asyncAfter(deadline: .now() + 30, execute: timer)
        }
    }

    func dismissAlert() {
        dismissTimer?.cancel()
        dismissTimer = nil
        isShowingAlert = false

        if let window = alertWindow {
            window.close()
            alertWindow = nil
        }
    }
}