# BigNotify Installation Guide

## Building from Source

### Prerequisites
- macOS 13.0 (Ventura) or later
- Xcode Command Line Tools
- Node.js (for create-dmg)

### Build Steps

1. Clone the repository:
```bash
git clone https://github.com/yourusername/bignotify.git
cd bignotify
```

2. Run the build script:
```bash
./build_app.sh
```

This will create:
- `build/BigNotify.app` - The application bundle
- `build/BigNotify-1.0.0.dmg` - DMG installer (if code signing is available)
- `build/BigNotify-1.0.0.zip` - ZIP archive for distribution

3. Install the app:
```bash
cp -r build/BigNotify.app /Applications/
```

## Installation via Homebrew Cask (Future)

Once the app is published to GitHub Releases:

```bash
# Add the tap (if using a custom tap)
brew tap yourusername/bignotify

# Install BigNotify
brew install --cask bignotify
```

## Manual Installation

1. Download the latest release from GitHub Releases
2. Extract the ZIP file
3. Drag BigNotify.app to your Applications folder
4. Launch BigNotify from Applications or Spotlight

## First Launch

On first launch:
1. BigNotify will request calendar access - click "Allow"
2. The app will appear as a bell icon in your menu bar
3. Click the menu bar icon to configure settings

## Creating a GitHub Release

To make the app installable via Homebrew Cask:

1. Build the app:
```bash
./build_app.sh
```

2. Create a new GitHub release:
   - Tag: `v1.0.0`
   - Upload `build/BigNotify-1.0.0.zip`

3. Get the SHA256 hash:
```bash
shasum -a 256 build/BigNotify-1.0.0.zip
```

4. Update `homebrew/bignotify.rb` with:
   - Your GitHub username
   - The SHA256 hash
   - The release URL

5. Submit to homebrew-cask or create your own tap:
```bash
# Option 1: Submit to official homebrew-cask
brew bump-cask-pr --version 1.0.0 bignotify

# Option 2: Create your own tap
# Create a new GitHub repo called homebrew-bignotify
# Add the bignotify.rb file to Formula/ directory
# Users can then: brew tap yourusername/bignotify
```

## Troubleshooting

### "App is damaged" error
This happens with unsigned apps. To fix:
```bash
xattr -cr /Applications/BigNotify.app
```

### Calendar Access
If calendar access wasn't granted:
1. Open System Settings
2. Go to Privacy & Security > Calendars
3. Enable BigNotify

### Building for Intel and Apple Silicon
The build script creates a universal binary that works on both architectures.