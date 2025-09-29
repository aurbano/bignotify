import SwiftUI
import AppKit

@main
struct BigNotifyApp: App {
    @StateObject private var alertManager = AlertManager()
    @StateObject private var calendarManager = CalendarManager()
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(alertManager)
                .environmentObject(calendarManager)
                .onAppear {
                    // Set up the app delegate references
                    appDelegate.alertManager = alertManager
                    appDelegate.calendarManager = calendarManager
                    // Hide the default window initially
                    if let window = NSApp.windows.first {
                        window.close()
                    }
                }
        }
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentSize)
    }
}

class AppDelegate: NSObject, NSApplicationDelegate, NSWindowDelegate {
    var statusItem: NSStatusItem?
    var alertManager: AlertManager?
    var calendarManager: CalendarManager?
    private var mainWindow: NSPanel?
    private var eventMonitor: Any?

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Hide from dock
        NSApp.setActivationPolicy(.accessory)

        // Create status bar item
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        if let button = statusItem?.button {
            button.image = NSImage(systemSymbolName: "bell.circle.fill", accessibilityDescription: "BigNotify")
            button.action = #selector(statusBarButtonClicked)
            button.target = self
        }
    }

    @objc func statusBarButtonClicked(_ sender: Any?) {
        if mainWindow?.isVisible == true {
            hideMainWindow()
        } else {
            showMainWindow()
        }
    }

    func showMainWindow() {
        if mainWindow == nil {
            // Create new window with ContentView
            let contentView = ContentView()
                .environmentObject(alertManager ?? AlertManager())
                .environmentObject(calendarManager ?? CalendarManager())

            // Use NSPanel for better behavior
            let panel = NSPanel(
                contentRect: NSRect(x: 0, y: 0, width: 400, height: 580),
                styleMask: [.borderless, .nonactivatingPanel],
                backing: .buffered,
                defer: false
            )

            panel.level = .floating
            panel.backgroundColor = NSColor.windowBackgroundColor
            panel.hasShadow = true
            panel.contentView = NSHostingView(rootView: contentView)
            panel.isReleasedWhenClosed = false
            panel.delegate = self
            panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
            panel.isMovableByWindowBackground = true

            mainWindow = panel
        }

        // Always refresh calendars when showing the window
        calendarManager?.loadCalendars()

        // Position window below status bar item
        if let button = statusItem?.button {
            let buttonFrame = button.frame
            let screenFrame = button.window?.screen?.frame ?? NSScreen.main?.frame ?? NSRect.zero

            // Position below the menu bar item with some padding
            let windowWidth: CGFloat = 400
            let windowHeight: CGFloat = 580
            let padding: CGFloat = 5
            let menuBarHeight: CGFloat = 22

            // Calculate x position - center under button but keep within screen bounds
            let buttonWindowX = button.window?.frame.origin.x ?? 0
            var x = buttonWindowX + buttonFrame.midX - (windowWidth / 2)

            // Ensure window doesn't go beyond screen edges
            let minX = screenFrame.minX + padding
            let maxX = screenFrame.maxX - windowWidth - padding
            x = max(minX, min(x, maxX))

            // Position just below menu bar
            let y = screenFrame.maxY - menuBarHeight - windowHeight - padding

            mainWindow?.setFrame(NSRect(x: x, y: y, width: windowWidth, height: windowHeight), display: true)
        }

        mainWindow?.makeKeyAndOrderFront(nil)

        // Monitor for clicks outside window
        eventMonitor = NSEvent.addGlobalMonitorForEvents(matching: [.leftMouseDown, .rightMouseDown]) { [weak self] event in
            if let window = self?.mainWindow, window.isVisible {
                let mouseLocation = NSEvent.mouseLocation
                if !window.frame.contains(mouseLocation) {
                    self?.hideMainWindow()
                }
            }
        }
    }

    func hideMainWindow() {
        mainWindow?.close()
        if let monitor = eventMonitor {
            NSEvent.removeMonitor(monitor)
            eventMonitor = nil
        }
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return false
    }
}