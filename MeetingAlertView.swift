import SwiftUI

struct MeetingAlertView: View {
    @EnvironmentObject var alertManager: AlertManager
    @State private var isAnimating = false

    var meetingURL: URL? {
        let location = alertManager.meetingLocation
        if location.isEmpty { return nil }

        // Check if location is a URL
        if location.lowercased().starts(with: "http") ||
           location.lowercased().starts(with: "zoom.us") ||
           location.lowercased().contains("zoom.us/") ||
           location.lowercased().contains("meet.google.com") {
            return URL(string: location)
        }
        return nil
    }

    var meetingIcon: String {
        let location = alertManager.meetingLocation.lowercased()

        if location.contains("zoom.us") || location.contains("zoom://") {
            return "video.circle.fill"
        } else if location.contains("meet.google.com") {
            return "video.square.fill"
        } else if location.contains("teams.microsoft.com") {
            return "person.3.fill"
        } else if location.contains("webex.com") {
            return "video.badge.checkmark"
        }
        return "video"
    }

    var meetingPlatform: String {
        let location = alertManager.meetingLocation.lowercased()

        if location.contains("zoom.us") || location.contains("zoom://") {
            return "Zoom"
        } else if location.contains("meet.google.com") {
            return "Google Meet"
        } else if location.contains("teams.microsoft.com") {
            return "Teams"
        } else if location.contains("webex.com") {
            return "Webex"
        }
        return ""
    }

    var body: some View {
        VStack(spacing: 0) {
            // Header with pulsing animation
            ZStack {
                Circle()
                    .fill(Color.red.opacity(0.2))
                    .frame(width: 100, height: 100)
                    .scaleEffect(isAnimating ? 1.3 : 1.0)
                    .opacity(isAnimating ? 0.0 : 1.0)
                    .animation(
                        Animation.easeInOut(duration: 1.5)
                            .repeatForever(autoreverses: false),
                        value: isAnimating
                    )

                Circle()
                    .fill(Color.red.gradient)
                    .frame(width: 80, height: 80)
                    .overlay(
                        Image(systemName: "bell.fill")
                            .font(.system(size: 40))
                            .foregroundColor(.white)
                    )
            }
            .padding(.top, 40)

            Spacer()
                .frame(height: 30)

            // Main content container with solid background
            VStack(spacing: 20) {
                // Meeting title
                Text(alertManager.meetingTitle)
                    .font(.system(size: 36, weight: .bold))

                // Time indicator
                Text(alertManager.meetingTime)
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundColor(.red)

                // Location with platform icon
                if !alertManager.meetingLocation.isEmpty {
                    HStack(spacing: 8) {
                        if meetingURL != nil {
                            Image(systemName: meetingIcon)
                                .foregroundColor(.blue)
                                .font(.title2)
                            if !meetingPlatform.isEmpty {
                                Text(meetingPlatform)
                                    .font(.system(size: 18, weight: .medium))
                                    .foregroundColor(.blue)
                            }
                        } else {
                            Image(systemName: "location.fill")
                                .foregroundColor(Color(NSColor.secondaryLabelColor))
                            Text(alertManager.meetingLocation)
                                .font(.system(size: 18))
                                .foregroundColor(Color(NSColor.secondaryLabelColor))
                        }
                    }
                }

                // Action buttons
                HStack(spacing: 20) {
                    Button(action: {
                        // Open Calendar app
                        NSWorkspace.shared.open(URL(string: "ical://")!)
                        alertManager.dismissAlert()
                    }) {
                        Text("Open Calendar")
                            .font(.headline)
                            .frame(width: 150)
                    }
                    .controlSize(.large)
                    .buttonStyle(.bordered)

                    if let url = meetingURL {
                        Button(action: {
                            NSWorkspace.shared.open(url)
                            alertManager.dismissAlert()
                        }) {
                            HStack(spacing: 6) {
                                Image(systemName: meetingIcon)
                                Text("Join Meeting")
                            }
                            .font(.headline)
                            .frame(width: 150)
                        }
                        .controlSize(.large)
                        .buttonStyle(.borderedProminent)
                    }
                }
            }
            .padding(30)
            .background(Color(NSColor.windowBackgroundColor), in: RoundedRectangle(cornerRadius: 12))

            Spacer()

            // Dismiss button
            Button(action: {
                alertManager.dismissAlert()
            }) {
                Text("Dismiss")
                    .font(.caption)
                    .foregroundColor(Color(NSColor.secondaryLabelColor))
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
            }
            .buttonStyle(.plain)
            .padding(.bottom, 20)
        }
        .frame(width: 500)
        .fixedSize(horizontal: false, vertical: true)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(.quaternary, lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.3), radius: 25, x: 0, y: 12)
        .onAppear {
            isAnimating = true
            // Play alert sound
            NSSound.beep()
        }
    }
}