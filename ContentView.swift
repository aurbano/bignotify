import SwiftUI

struct ContentView: View {
    @EnvironmentObject var alertManager: AlertManager
    @EnvironmentObject var calendarManager: CalendarManager
    @StateObject private var settingsManager = SettingsManager()
    @State private var showingCalendarPicker = false
    @State private var isHoveringMeeting = false

    var body: some View {
        VStack(spacing: 15) {
            Text("BigNotify")
                .font(.system(size: 24, weight: .semibold))

            Divider()
                .padding(.vertical, 5)

            // Calendar Access Status
            if !calendarManager.hasAccess {
                VStack(spacing: 10) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.largeTitle)
                        .foregroundColor(.orange)

                    Text(calendarManager.accessStatus)
                        .font(.caption)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.secondary)

                    Button("Open System Settings") {
                        NSWorkspace.shared.open(URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Calendars")!)
                    }
                    .buttonStyle(.borderedProminent)
                }
                .padding()
                .background(Color.orange.opacity(0.1))
                .cornerRadius(10)
            } else {
                // Next Meeting Display
                VStack(alignment: .leading, spacing: 15) {
                    Text("Next Meeting")
                        .font(.headline)

                    if let nextEvent = calendarManager.nextEvent {
                        VStack(alignment: .leading, spacing: 10) {
                            Text(nextEvent.title)
                                .font(.title3)
                                .fontWeight(.medium)
                                .foregroundColor(.primary)

                            HStack {
                                Image(systemName: "clock")
                                    .foregroundColor(.blue)
                                Text(calendarManager.formatEventTime(nextEvent))
                                    .foregroundColor(.primary)
                                Spacer()
                                Text(calendarManager.timeUntilEvent(nextEvent))
                                    .foregroundColor(.secondary)
                                    .font(.caption)
                            }

                            if let location = nextEvent.location, !location.isEmpty {
                                HStack {
                                    Image(systemName: "location")
                                        .foregroundColor(.gray)
                                    Text(location)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.blue.opacity(isHoveringMeeting ? 0.15 : 0.1))
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.blue.opacity(isHoveringMeeting ? 0.3 : 0.2), lineWidth: 1)
                        )
                        .contentShape(Rectangle())
                        .onTapGesture {
                            alertManager.showAlert(
                                title: nextEvent.title,
                                time: "Starting at \(calendarManager.formatEventTime(nextEvent))",
                                location: nextEvent.location ?? ""
                            )
                        }
                        .onHover { hovering in
                            isHoveringMeeting = hovering
                        }
                        .help("Click to preview alert")
                    } else {
                        Text("No upcoming meetings today")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(10)
                    }
                }

                // Upcoming events list
                if calendarManager.upcomingEvents.count > 1 {
                    VStack(alignment: .leading, spacing: 5) {
                        Text("Later Today")
                            .font(.caption)
                            .foregroundColor(.secondary)

                        ForEach(Array(calendarManager.upcomingEvents.dropFirst().prefix(3)), id: \.calendarItemIdentifier) { event in
                            HStack {
                                Text(calendarManager.formatEventTime(event))
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .frame(width: 60, alignment: .leading)
                                Text(event.title)
                                    .font(.caption)
                                    .lineLimit(1)
                            }
                        }
                    }
                    .padding(10)
                    .background(Color.gray.opacity(0.05))
                    .cornerRadius(8)
                }
            }

            Spacer()

            // Settings Section
            VStack(alignment: .leading, spacing: 15) {
                Text("Settings")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.secondary)

                VStack(alignment: .leading, spacing: 10) {
                    // Open at login
                    Toggle(isOn: $settingsManager.openAtLogin) {
                        HStack(spacing: 6) {
                            Image(systemName: "power")
                                .font(.system(size: 12))
                                .foregroundColor(.secondary)
                                .frame(width: 16)
                            Text("Open at login")
                                .font(.system(size: 13))
                        }
                    }
                    .toggleStyle(.checkbox)

                    // Skip meetings without location
                    Toggle(isOn: $settingsManager.skipMeetingsWithoutLocation) {
                        HStack(spacing: 6) {
                            Image(systemName: "location.slash")
                                .font(.system(size: 12))
                                .foregroundColor(.secondary)
                                .frame(width: 16)
                            Text("Skip meetings without location")
                                .font(.system(size: 13))
                        }
                    }
                    .toggleStyle(.checkbox)

                    // Calendar selection toggle
                    Toggle(isOn: $showingCalendarPicker) {
                        HStack(spacing: 6) {
                            Image(systemName: "calendar")
                                .font(.system(size: 12))
                                .foregroundColor(.secondary)
                                .frame(width: 16)
                            Text("Select calendars")
                                .font(.system(size: 13))
                        }
                    }
                    .toggleStyle(.checkbox)

                    // Show calendar list when toggled
                    if showingCalendarPicker && !calendarManager.calendars.isEmpty {
                        VStack(alignment: .leading, spacing: 6) {
                            ForEach(calendarManager.calendars.sorted(by: { $0.title < $1.title }), id: \.calendarIdentifier) { calendar in
                                HStack(spacing: 8) {
                                    // Indent for hierarchy
                                    Color.clear
                                        .frame(width: 20)

                                    Circle()
                                        .fill(Color(calendar.color ?? NSColor.systemBlue))
                                        .frame(width: 8, height: 8)

                                    Toggle(isOn: Binding(
                                        get: { settingsManager.isCalendarSelected(calendar.calendarIdentifier) },
                                        set: { _ in
                                            settingsManager.toggleCalendar(calendar.calendarIdentifier)
                                            calendarManager.loadUpcomingEvents()
                                        }
                                    )) {
                                        Text(calendar.title)
                                            .font(.system(size: 12))
                                            .lineLimit(1)
                                    }
                                    .toggleStyle(.checkbox)
                                    .controlSize(.small)
                                }
                            }
                        }
                        .padding(.vertical, 8)
                        .padding(.horizontal, 12)
                        .background(Color(NSColor.controlBackgroundColor))
                        .cornerRadius(6)
                    }

                    // Show selected calendars summary
                    if !showingCalendarPicker && !calendarManager.calendars.isEmpty {
                        let selectedCalendars = calendarManager.calendars.filter {
                            settingsManager.isCalendarSelected($0.calendarIdentifier)
                        }

                        if !selectedCalendars.isEmpty && selectedCalendars.count < calendarManager.calendars.count {
                            HStack(spacing: 4) {
                                Color.clear
                                    .frame(width: 22)

                                Text("Monitoring: ")
                                    .font(.system(size: 11))
                                    .foregroundColor(.secondary)

                                HStack(spacing: 4) {
                                    ForEach(selectedCalendars.prefix(3).sorted(by: { $0.title < $1.title }), id: \.calendarIdentifier) { calendar in
                                        HStack(spacing: 2) {
                                            Circle()
                                                .fill(Color(calendar.color ?? NSColor.systemBlue))
                                                .frame(width: 6, height: 6)
                                            Text(calendar.title)
                                                .font(.system(size: 11))
                                                .lineLimit(1)
                                        }
                                    }

                                    if selectedCalendars.count > 3 {
                                        Text("+\(selectedCalendars.count - 3) more")
                                            .font(.system(size: 11))
                                            .foregroundColor(.secondary)
                                    }
                                }

                                Spacer()
                            }
                        } else if selectedCalendars.count == calendarManager.calendars.count || settingsManager.selectedCalendarIDs.isEmpty {
                            HStack(spacing: 4) {
                                Color.clear
                                    .frame(width: 22)

                                Text("Monitoring all calendars")
                                    .font(.system(size: 11))
                                    .foregroundColor(.secondary)

                                Spacer()
                            }
                        }
                    }
                }
            }
            .padding(12)
            .background(Color(NSColor.windowBackgroundColor))
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
            )
            .cornerRadius(8)

            Button(action: {
                NSApplication.shared.terminate(nil)
            }) {
                HStack(spacing: 4) {
                    Image(systemName: "power.circle")
                        .font(.system(size: 12))
                    Text("Quit BigNotify")
                        .font(.system(size: 13))
                }
                .frame(maxWidth: .infinity)
            }
            .controlSize(.regular)
            .buttonStyle(.bordered)
        }
        .padding(20)
        .frame(width: 400, height: 580)
        .onAppear {
            calendarManager.loadCalendars()
        }
    }
}