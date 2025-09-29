import SwiftUI

struct ContentView: View {
    @EnvironmentObject var alertManager: AlertManager
    @EnvironmentObject var calendarManager: CalendarManager
    @StateObject private var settingsManager = SettingsManager()
    @State private var isHoveringMeeting = false
    @State private var isSettingsExpanded = false

    var body: some View {
        VStack(spacing: 15) {

            // Calendar Access Status
            if !calendarManager.hasAccess {
                VStack(spacing: 10) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.largeTitle)
                        .foregroundColor(.orange)

                    Text(calendarManager.accessStatus)
                        .font(.caption)
                        .multilineTextAlignment(.center)
                        .foregroundColor(Color(NSColor.secondaryLabelColor))

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
                        let calendarColor = Color(nextEvent.calendar?.color ?? NSColor.systemBlue)

                        VStack(alignment: .leading, spacing: 10) {
                            Text(nextEvent.title)
                                .font(.title3)
                                .fontWeight(.medium)
                                .foregroundColor(.primary)

                            HStack {
                                Image(systemName: "clock")
                                    .foregroundColor(calendarColor)
                                Text(calendarManager.formatEventTime(nextEvent))
                                    .foregroundColor(.primary)
                                Spacer()
                                Text(calendarManager.timeUntilEvent(nextEvent))
                                    .foregroundColor(Color(NSColor.secondaryLabelColor))
                                    .font(.caption)
                            }

                            if let location = nextEvent.location, !location.isEmpty {
                                HStack {
                                    Image(systemName: "location")
                                        .foregroundColor(.gray)
                                    Text(location)
                                        .font(.caption)
                                        .foregroundColor(Color(NSColor.secondaryLabelColor))
                                }
                            }
                        }
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(calendarColor.opacity(isHoveringMeeting ? 0.15 : 0.1))
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(calendarColor.opacity(isHoveringMeeting ? 0.3 : 0.2), lineWidth: 1)
                        )
                        .overlay(
                            // Left border accent
                            HStack {
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(calendarColor)
                                    .frame(width: 4)
                                Spacer()
                            }
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
                            .foregroundColor(Color(NSColor.secondaryLabelColor))
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
                            .foregroundColor(Color(NSColor.secondaryLabelColor))

                        ForEach(Array(calendarManager.upcomingEvents.dropFirst().prefix(3)), id: \.calendarItemIdentifier) { event in
                            HStack {
                                Text(calendarManager.formatEventTime(event))
                                    .font(.caption)
                                    .foregroundColor(Color(NSColor.secondaryLabelColor))
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

            // Settings Accordion
            VStack(alignment: .leading, spacing: 0) {
                // Header
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        isSettingsExpanded.toggle()
                    }
                }) {
                    HStack {
                        Text("Settings")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(Color(NSColor.secondaryLabelColor))

                        Spacer()

                        Image(systemName: "chevron.down")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(Color(NSColor.tertiaryLabelColor))
                            .rotationEffect(.degrees(isSettingsExpanded ? 0 : -90))
                    }
                    .padding(12)
                    .background(Color(NSColor.windowBackgroundColor))
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)

                // Content (collapsed by default)
                if isSettingsExpanded {
                    VStack(alignment: .leading, spacing: 15) {
                        // Monitored Calendars
                        if !calendarManager.calendars.isEmpty {
                            VStack(alignment: .leading, spacing: 10) {
                                Text("Monitored calendars")
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundColor(.primary)

                                VStack(alignment: .leading, spacing: 0) {
                                    ForEach(calendarManager.calendars.sorted(by: { $0.title < $1.title }), id: \.calendarIdentifier) { calendar in
                                        let isSelected = settingsManager.isCalendarSelected(calendar.calendarIdentifier)

                                        HStack(spacing: 10) {
                                            Circle()
                                                .fill(Color(calendar.color ?? NSColor.systemBlue))
                                                .frame(width: 10, height: 10)

                                            Text(calendar.title)
                                                .font(.system(size: 12))
                                                .lineLimit(1)
                                                .foregroundColor(isSelected ? .primary : Color(NSColor.secondaryLabelColor))

                                            Spacer()

                                            if isSelected {
                                                Image(systemName: "checkmark")
                                                    .font(.system(size: 10, weight: .medium))
                                                    .foregroundColor(.accentColor)
                                            }
                                        }
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .background(
                                            RoundedRectangle(cornerRadius: 4)
                                                .fill(isSelected ? Color.accentColor.opacity(0.1) : Color.clear)
                                        )
                                        .contentShape(Rectangle())
                                        .onTapGesture {
                                            settingsManager.toggleCalendar(calendar.calendarIdentifier)
                                            calendarManager.loadUpcomingEvents()
                                        }
                                        .animation(.easeInOut(duration: 0.15), value: isSelected)
                                    }
                                }
                                .padding(.vertical, 4)
                                .background(Color(NSColor.controlBackgroundColor))
                                .cornerRadius(6)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 6)
                                        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                                )
                            }
                        }

                        // App Settings
                        VStack(alignment: .leading, spacing: 10) {
                            Text("App settings")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.primary)

                            VStack(alignment: .leading, spacing: 8) {
                                // Open at login
                                Toggle(isOn: $settingsManager.openAtLogin) {
                                    HStack(spacing: 6) {
                                        Image(systemName: "power")
                                            .font(.system(size: 12))
                                            .foregroundColor(Color(NSColor.secondaryLabelColor))
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
                                            .foregroundColor(Color(NSColor.secondaryLabelColor))
                                            .frame(width: 16)
                                        Text("Skip meetings without location")
                                            .font(.system(size: 13))
                                    }
                                }
                                .toggleStyle(.checkbox)
                            }
                        }
                    }
                    .padding(12)
                    .background(Color(NSColor.controlBackgroundColor).opacity(0.5))
                    .transition(.asymmetric(
                        insertion: .move(edge: .top).combined(with: .opacity),
                        removal: .move(edge: .top).combined(with: .opacity)
                    ))
                }
            }
            .frame(maxWidth: .infinity)
            .background(Color(NSColor.windowBackgroundColor))
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
            )
            .cornerRadius(8)
            .animation(.easeInOut(duration: 0.2), value: isSettingsExpanded)
        }
        .padding(20)
        .frame(width: 400)
        .fixedSize(horizontal: false, vertical: true)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(.quaternary, lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.25), radius: 20, x: 0, y: 8)
        .onAppear {
            calendarManager.setSettingsManager(settingsManager)
            calendarManager.loadCalendars()
        }
    }
}