# 🔔 BigNotify

Automatically monitors selected macOS calendars and displays big alert windows whenever you have a meeting

![GitHub release (latest by date)](https://img.shields.io/github/v/release/aurbano/bignotify)
![macOS](https://img.shields.io/badge/macOS-13.0+-blue)
![Swift](https://img.shields.io/badge/Swift-5.9-orange)


## When a meeting starts:
<img width="500" height="467" alt="Screenshot 2025-09-29 at 14 04 55" src="https://github.com/user-attachments/assets/b00ed8ef-7087-4b68-af26-aa2636d3cc42" />


## App window and settings:
<img width="400" height="688" alt="Screenshot 2025-09-29 at 14 04 38" src="https://github.com/user-attachments/assets/e242fa47-46ee-4e47-b85f-bcabf3a6b586" />


## Installation

### Option 1: Download Latest Release (Recommended)

1. Download the latest `.zip` from [Releases](https://github.com/aurbano/bignotify/releases)
2. Extract and drag `BigNotify.app` to your Applications folder
3. Right-click and select "Open" on first launch (app is not notarized yet)

### Option 3: Build from Source

See [INSTALL.md](INSTALL.md) for detailed build instructions.

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
