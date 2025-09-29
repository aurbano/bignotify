import SwiftUI
import ServiceManagement

class SettingsManager: ObservableObject {
    @AppStorage("openAtLogin") var openAtLogin = false {
        didSet {
            updateLoginItem()
        }
    }

    @AppStorage("skipMeetingsWithoutLocation") var skipMeetingsWithoutLocation = false
    @AppStorage("selectedCalendarIDs") private var selectedCalendarIDsData = Data()

    @Published var selectedCalendarIDs: Set<String> = [] {
        didSet {
            saveSelectedCalendars()
        }
    }

    init() {
        loadSelectedCalendars()
    }

    private func updateLoginItem() {
        do {
            if openAtLogin {
                try SMAppService.mainApp.register()
            } else {
                try SMAppService.mainApp.unregister()
            }
        } catch {
            print("Failed to update login item: \(error)")
        }
    }

    private func saveSelectedCalendars() {
        if let data = try? JSONEncoder().encode(Array(selectedCalendarIDs)) {
            selectedCalendarIDsData = data
        }
    }

    private func loadSelectedCalendars() {
        if let ids = try? JSONDecoder().decode([String].self, from: selectedCalendarIDsData) {
            selectedCalendarIDs = Set(ids)
        }
    }

    func isCalendarSelected(_ calendarID: String) -> Bool {
        // If no calendars selected, treat all as selected
        if selectedCalendarIDs.isEmpty {
            return true
        }
        return selectedCalendarIDs.contains(calendarID)
    }

    func toggleCalendar(_ calendarID: String) {
        if selectedCalendarIDs.contains(calendarID) {
            selectedCalendarIDs.remove(calendarID)
        } else {
            selectedCalendarIDs.insert(calendarID)
        }
    }
}