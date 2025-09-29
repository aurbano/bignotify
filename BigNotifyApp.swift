import SwiftUI
import AppKit

@main
struct BigNotifyApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate


    var body: some Scene {
        // Use Settings scene instead of WindowGroup for menu bar apps
        Settings {
            EmptyView()
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate, NSWindowDelegate {
    var statusItem: NSStatusItem?
    var alertManager: AlertManager?
    var calendarManager: CalendarManager?
    private var mainWindow: NSPanel?
    private var eventMonitor: Any?


    func applicationDidFinishLaunching(_ notification: Notification) {
        // Initialize managers
        alertManager = AlertManager()
        calendarManager = CalendarManager()

        // Connect the managers
        calendarManager?.setAlertManager(alertManager!)

        // Hide from dock
        NSApp.setActivationPolicy(.accessory)

        // Create status bar item
        createStatusBarItem()
    }

    private func createStatusBarItem() {
        // Create status bar item with variable length that adapts to content
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        // Force the status item to be visible
        statusItem?.isVisible = true
        statusItem?.behavior = .removalAllowed

        if let button = statusItem?.button {
            // Use SF Symbol with proper template mode
            if let image = NSImage(systemSymbolName: "bell", accessibilityDescription: "BigNotify") {
                image.isTemplate = true
                // Set a specific size for the icon
                image.size = NSSize(width: 16, height: 16)
                button.image = image
                button.imagePosition = .imageOnly
            } else {
                button.title = "🔔"
            }

            button.action = #selector(statusBarButtonClicked)
            button.target = self
            button.toolTip = "BigNotify - Calendar Alerts"

            // Add right-click detection
            button.sendAction(on: [.leftMouseUp, .rightMouseUp])

            // Force button to update
            button.needsDisplay = true
        }
    }

    @objc func statusBarButtonClicked() {
        guard let event = NSApp.currentEvent else { return }

        if event.type == .rightMouseUp {
            // Show context menu on right-click
            let menu = NSMenu()

            let quitItem = NSMenuItem(title: "Quit BigNotify", action: #selector(quitApp), keyEquivalent: "q")
            quitItem.target = self

            menu.addItem(quitItem)

            statusItem?.menu = menu
            statusItem?.button?.performClick(nil)
            statusItem?.menu = nil  // Clear menu after showing
        } else {
            // Normal left-click behavior
            if mainWindow?.isVisible == true {
                hideMainWindow()
            } else {
                showMainWindow()
            }
        }
    }

    @objc func quitApp() {
        NSApplication.shared.terminate(nil)
    }

    func showMainWindow() {
        // Ensure managers are available
        guard let alertManager = self.alertManager,
              let calendarManager = self.calendarManager else {
            return
        }

        if mainWindow == nil {

            // Create the actual ContentView with proper initialization
            let contentView = ContentView()
                .environmentObject(alertManager)
                .environmentObject(calendarManager)

            // Create the hosting controller and get its size
            let hostingView = NSHostingView(rootView: contentView)
            let fittingSize = hostingView.fittingSize
            let windowWidth: CGFloat = 400
            let windowHeight = max(fittingSize.height, 200) // Minimum height of 200

            // Create NSPanel with dynamic size and native macOS styling
            let panel = NSPanel(
                contentRect: NSRect(x: 0, y: 0, width: windowWidth, height: windowHeight),
                styleMask: [.borderless, .nonactivatingPanel],
                backing: .buffered,
                defer: false
            )

            panel.level = .floating
            panel.backgroundColor = NSColor.clear
            panel.isOpaque = false
            panel.hasShadow = true
            panel.contentView = hostingView

            panel.isReleasedWhenClosed = false
            panel.delegate = self
            panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
            panel.isMovableByWindowBackground = true

            mainWindow = panel
        }

        // Always refresh calendars when showing the window
        calendarManager.loadCalendars()

        // Position window below status bar item
        if let button = statusItem?.button {
            let buttonFrame = button.frame
            let screenFrame = button.window?.screen?.frame ?? NSScreen.main?.frame ?? NSRect.zero

            let windowWidth: CGFloat = 400
            let windowHeight = mainWindow?.frame.height ?? 200
            let padding: CGFloat = 5
            let menuBarHeight: CGFloat = 22

            let buttonWindowX = button.window?.frame.origin.x ?? 0
            var x = buttonWindowX + buttonFrame.midX - (windowWidth / 2)

            let minX = screenFrame.minX + padding
            let maxX = screenFrame.maxX - windowWidth - padding
            x = max(minX, min(x, maxX))

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

    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        // Always show main window when app is reopened (from dock, spotlight, etc.)
        showMainWindow()
        return true
    }
}