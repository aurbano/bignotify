#!/bin/bash

# Build script for BigNotify.app

set -e

APP_NAME="BigNotify"
BUNDLE_ID="com.bignotify.app"
VERSION="1.0.0"
BUILD_DIR="build"
APP_DIR="$BUILD_DIR/$APP_NAME.app"
CONTENTS_DIR="$APP_DIR/Contents"
MACOS_DIR="$CONTENTS_DIR/MacOS"
RESOURCES_DIR="$CONTENTS_DIR/Resources"

echo "Building BigNotify.app..."

# Clean and create build directory
rm -rf "$BUILD_DIR"
mkdir -p "$MACOS_DIR"
mkdir -p "$RESOURCES_DIR"

# Build the binary
echo "Compiling Swift code..."

# Check if we're on Apple Silicon or Intel
ARCH=$(uname -m)

if [[ "$ARCH" == "arm64" ]]; then
    echo "Building for Apple Silicon..."
    swift build -c release --arch arm64

    # Create output directory
    mkdir -p ".build/apple/Products/Release"

    # Also try to build for Intel if possible (for universal binary)
    if swift build -c release --arch x86_64 2>/dev/null; then
        echo "Creating universal binary..."
        lipo -create \
            ".build/arm64-apple-macosx/release/BigNotify" \
            ".build/x86_64-apple-macosx/release/BigNotify" \
            -output ".build/apple/Products/Release/BigNotify"
    else
        echo "Could not build for x86_64, creating Apple Silicon only build"
        cp ".build/arm64-apple-macosx/release/BigNotify" ".build/apple/Products/Release/BigNotify"
    fi
elif [[ "$ARCH" == "x86_64" ]]; then
    echo "Building for Intel..."
    swift build -c release --arch x86_64
    mkdir -p ".build/apple/Products/Release"
    cp ".build/x86_64-apple-macosx/release/BigNotify" ".build/apple/Products/Release/BigNotify"
else
    echo "Building for current architecture..."
    swift build -c release
fi

# Ensure the binary exists
if [[ ! -f ".build/apple/Products/Release/BigNotify" ]]; then
    # Fallback: find the binary wherever it was built
    BINARY_PATH=$(find .build -name "BigNotify" -type f -path "*/release/*" | head -1)
    if [[ -n "$BINARY_PATH" ]]; then
        echo "Found binary at: $BINARY_PATH"
        mkdir -p ".build/apple/Products/Release"
        cp "$BINARY_PATH" ".build/apple/Products/Release/BigNotify"
    else
        echo "Error: Could not find compiled binary"
        exit 1
    fi
fi

# Copy binary
cp ".build/apple/Products/Release/BigNotify" "$MACOS_DIR/$APP_NAME"

# Create Info.plist
cat > "$CONTENTS_DIR/Info.plist" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleDisplayName</key>
    <string>BigNotify</string>
    <key>CFBundleExecutable</key>
    <string>BigNotify</string>
    <key>CFBundleIconFile</key>
    <string>AppIcon</string>
    <key>CFBundleIdentifier</key>
    <string>$BUNDLE_ID</string>
    <key>CFBundleName</key>
    <string>BigNotify</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleShortVersionString</key>
    <string>$VERSION</string>
    <key>CFBundleVersion</key>
    <string>1</string>
    <key>LSApplicationCategoryType</key>
    <string>public.app-category.productivity</string>
    <key>LSMinimumSystemVersion</key>
    <string>13.0</string>
    <key>LSUIElement</key>
    <true/>
    <key>NSCalendarsUsageDescription</key>
    <string>BigNotify needs access to your calendar to show meeting alerts.</string>
    <key>NSHighResolutionCapable</key>
    <true/>
    <key>NSSupportsAutomaticTermination</key>
    <false/>
    <key>NSMainNibFile</key>
    <string></string>
    <key>NSPrincipalClass</key>
    <string>NSApplication</string>
</dict>
</plist>
EOF

# Create AppIcon.icns from icon.png if it exists
# if [ -f "icon.png" ]; then
#     echo "Creating app icon..."
#     mkdir -p "$RESOURCES_DIR/AppIcon.iconset"

#     # Generate different icon sizes
#     sips -z 16 16     icon.png --out "$RESOURCES_DIR/AppIcon.iconset/icon_16x16.png"
#     sips -z 32 32     icon.png --out "$RESOURCES_DIR/AppIcon.iconset/icon_16x16@2x.png"
#     sips -z 32 32     icon.png --out "$RESOURCES_DIR/AppIcon.iconset/icon_32x32.png"
#     sips -z 64 64     icon.png --out "$RESOURCES_DIR/AppIcon.iconset/icon_32x32@2x.png"
#     sips -z 128 128   icon.png --out "$RESOURCES_DIR/AppIcon.iconset/icon_128x128.png"
#     sips -z 256 256   icon.png --out "$RESOURCES_DIR/AppIcon.iconset/icon_128x128@2x.png"
#     sips -z 256 256   icon.png --out "$RESOURCES_DIR/AppIcon.iconset/icon_256x256.png"
#     sips -z 512 512   icon.png --out "$RESOURCES_DIR/AppIcon.iconset/icon_256x256@2x.png"
#     sips -z 512 512   icon.png --out "$RESOURCES_DIR/AppIcon.iconset/icon_512x512.png"
#     sips -z 1024 1024 icon.png --out "$RESOURCES_DIR/AppIcon.iconset/icon_512x512@2x.png"

#     # Create icns file
#     iconutil -c icns "$RESOURCES_DIR/AppIcon.iconset" -o "$RESOURCES_DIR/AppIcon.icns"

#     # Clean up iconset
#     rm -rf "$RESOURCES_DIR/AppIcon.iconset"
# fi

# Sign the app if certificate is available
ENTITLEMENTS_FILE="BigNotify.entitlements"
if [[ -n "${APPLE_DEVELOPER_ID}" ]]; then
    echo "Signing app with certificate: ${APPLE_DEVELOPER_ID}"
    if [[ -f "$ENTITLEMENTS_FILE" ]]; then
        codesign --force --deep --entitlements "$ENTITLEMENTS_FILE" --sign "${APPLE_DEVELOPER_ID}" "$APP_DIR"
    else
        codesign --force --deep --sign "${APPLE_DEVELOPER_ID}" "$APP_DIR"
    fi

    # Verify the signature
    codesign --verify --deep --strict "$APP_DIR"
    spctl --assess --type exec "$APP_DIR" || echo "Note: Gatekeeper verification may fail for ad-hoc signed apps"
else
    echo "No Developer ID certificate provided. Using ad-hoc signing..."
    # Ad-hoc sign with entitlements (makes the app run more smoothly on the build machine at least)
    if [[ -f "$ENTITLEMENTS_FILE" ]]; then
        echo "Using entitlements file: $ENTITLEMENTS_FILE"
        codesign --force --deep --entitlements "$ENTITLEMENTS_FILE" --sign - "$APP_DIR"
    else
        codesign --force --deep --sign - "$APP_DIR"
    fi
    echo "App is ad-hoc signed. Users will need to:"
    echo "  1. Right-click and select 'Open' on first launch, OR"
    echo "  2. Run: xattr -cr /Applications/BigNotify.app"
fi

echo "Creating ZIP..."
cd "$BUILD_DIR"
zip -r "$APP_NAME-$VERSION.zip" "$APP_NAME.app"
cd ..

echo ""
echo "Installing to Applications directory..."
# Kill any running instances first
killall BigNotify 2>/dev/null || true

# Remove existing app if it exists and copy new one
rm -rf "/Applications/BigNotify.app"
cp -r "$APP_DIR" "/Applications/"

echo ""
echo "Build complete!"
echo "  App bundle: $APP_DIR"
echo "  Installed to: /Applications/BigNotify.app"
echo ""
echo "  ZIP: $BUILD_DIR/$APP_NAME-$VERSION.zip"
echo ""
echo "To distribute:"
echo "  Upload $BUILD_DIR/$APP_NAME-$VERSION.zip to GitHub Releases"