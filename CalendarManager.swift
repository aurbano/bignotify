import SwiftUI
import EventKit
import Combine

class CalendarManager: ObservableObject {
    @Published var calendars: [EKCalendar] = []
    @Published var nextEvent: EKEvent?
    @Published var upcomingEvents: [EKEvent] = []
    @Published var hasAccess = false
    @Published var accessStatus = ""

    private let eventStore = EKEventStore()
    private var timer: Timer?

    init() {
        requestAccess()
        startMonitoring()
    }

    func requestAccess() {
        if #available(macOS 14.0, *) {
            eventStore.requestFullAccessToEvents { [weak self] granted, error in
                DispatchQueue.main.async {
                    self?.hasAccess = granted
                    if granted {
                        self?.accessStatus = "Calendar access granted"
                        self?.loadCalendars()
                    } else {
                        self?.accessStatus = "Calendar access denied. Please grant access in System Settings > Privacy & Security > Calendars"
                    }
                }
            }
        } else {
            // For macOS 13 and earlier
            eventStore.requestAccess(to: .event) { [weak self] granted, error in
                DispatchQueue.main.async {
                    self?.hasAccess = granted
                    if granted {
                        self?.accessStatus = "Calendar access granted"
                        self?.loadCalendars()
                    } else {
                        self?.accessStatus = "Calendar access denied. Please grant access in System Settings > Privacy & Security > Calendars"
                    }
                }
            }
        }
    }

    func loadCalendars() {
        guard hasAccess else { return }

        calendars = eventStore.calendars(for: .event)
        loadUpcomingEvents()
    }

    func loadUpcomingEvents() {
        guard hasAccess else { return }

        let now = Date()
        let endDate = Calendar.current.date(byAdding: .day, value: 1, to: now)!

        // Get settings
        let settingsManager = SettingsManager()

        // Filter calendars based on settings
        var calendarsToSearch: [EKCalendar]?
        if !settingsManager.selectedCalendarIDs.isEmpty {
            calendarsToSearch = calendars.filter { calendar in
                settingsManager.isCalendarSelected(calendar.calendarIdentifier)
            }
        } else {
            calendarsToSearch = calendars.isEmpty ? nil : calendars
        }

        let predicate = eventStore.predicateForEvents(
            withStart: now,
            end: endDate,
            calendars: calendarsToSearch
        )

        var events = eventStore.events(matching: predicate)
            .filter { !$0.isAllDay }

        // Filter out events without location if setting is enabled
        if settingsManager.skipMeetingsWithoutLocation {
            events = events.filter { event in
                if let location = event.location, !location.isEmpty {
                    return true
                }
                return false
            }
        }

        events.sort { $0.startDate < $1.startDate }

        DispatchQueue.main.async { [weak self] in
            self?.upcomingEvents = events
            self?.nextEvent = events.first
        }
    }

    func formatEventTime(_ event: EKEvent) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: event.startDate)
    }

    func timeUntilEvent(_ event: EKEvent) -> String {
        let interval = event.startDate.timeIntervalSince(Date())
        if interval < 0 {
            return "Started"
        } else if interval < 60 {
            return "Less than 1 minute"
        } else if interval < 3600 {
            let minutes = Int(interval / 60)
            return "\(minutes) minute\(minutes == 1 ? "" : "s")"
        } else {
            let hours = Int(interval / 3600)
            let minutes = Int((interval.truncatingRemainder(dividingBy: 3600)) / 60)
            if minutes > 0 {
                return "\(hours) hour\(hours == 1 ? "" : "s") \(minutes) min"
            } else {
                return "\(hours) hour\(hours == 1 ? "" : "s")"
            }
        }
    }

    private func startMonitoring() {
        // Refresh events every minute
        timer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { [weak self] _ in
            self?.loadCalendars()  // This will also call loadUpcomingEvents
            self?.checkForUpcomingMeetings()
        }
    }

    private func checkForUpcomingMeetings() {
        guard let nextEvent = nextEvent else { return }

        let settingsManager = SettingsManager()

        // Skip if meeting has no location and setting is enabled
        if settingsManager.skipMeetingsWithoutLocation {
            if nextEvent.location == nil || nextEvent.location?.isEmpty == true {
                return
            }
        }

        let timeUntil = nextEvent.startDate.timeIntervalSince(Date())

        // Alert when meeting is starting (within 30 seconds)
        if timeUntil > -30 && timeUntil < 30 {
            let alertManager = AlertManager()
            alertManager.showAlert(
                title: nextEvent.title,
                time: "Starting Now!",
                location: nextEvent.location ?? ""
            )
        }
    }

    deinit {
        timer?.invalidate()
    }
}
