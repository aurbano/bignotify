# 🔔 BigNotify

A macOS menu bar app that ensures you never miss a meeting by displaying prominent, center-screen notifications for calendar events.

![GitHub release (latest by date)](https://img.shields.io/github/v/release/aurbano/bignotify)
![macOS](https://img.shields.io/badge/macOS-13.0+-blue)
![Swift](https://img.shields.io/badge/Swift-5.9-orange)
[![CI](https://github.com/aurbano/bignotify/actions/workflows/ci.yml/badge.svg)](https://github.com/aurbano/bignotify/actions)

## ✨ Features

- **Prominent Alerts**: Large, center-screen notifications that are impossible to miss
- **Calendar Integration**: Automatically monitors all your macOS calendars
- **Smart Meeting Links**: Detects Zoom, Google Meet, Teams, and Webex links
- **Customizable Settings**:
  - Select which calendars to monitor
  - Skip meetings without locations
  - Open at login option
- **Native macOS Design**: Built with SwiftUI for a seamless Mac experience
- **Menu Bar Only**: Stays out of your way in the menu bar, no dock icon

## 📸 Screenshots

<details>
<summary>Click to view screenshots</summary>

### Menu Bar App
The app lives in your menu bar and shows your next meeting at a glance.

### Meeting Alert
When a meeting is about to start, you'll see this prominent alert in the center of your screen.

### Settings
Easily configure which calendars to monitor and other preferences.

</details>

## 📦 Installation

### Option 1: Download Latest Release (Recommended)

1. Download the latest `.zip` from [Releases](https://github.com/aurbano/bignotify/releases)
2. Extract and drag `BigNotify.app` to your Applications folder
3. Right-click and select "Open" on first launch (app is not notarized yet)

### Option 3: Build from Source

See [INSTALL.md](INSTALL.md) for detailed build instructions.

## 🚀 Usage

1. **Launch BigNotify** from Applications or Spotlight
2. **Grant Calendar Access** when prompted
3. **Click the bell icon** in your menu bar to:
   - View your next meeting
   - Configure settings
   - Select which calendars to monitor
4. **Receive alerts** automatically when meetings are about to start

### Features in Detail

- **Click on Next Meeting**: Preview how the alert will look
- **Calendar Selection**: Choose specific calendars to monitor
- **Smart Filtering**: Option to skip meetings without location/URL
- **Auto-Refresh**: Calendar data updates every minute

## 🛠 Development

### Prerequisites

- macOS 13.0 (Ventura) or later
- Xcode 15.0 or later
- Swift 5.9+

### Building

```bash
# Clone the repository
git clone https://github.com/aurbano/bignotify.git
cd bignotify

# Build with Swift Package Manager
swift build

# Or build the app bundle
./build_app.sh
```
