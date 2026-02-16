#!/bin/bash
set -e

echo "Building KA Window..."
swift build

APP_BUNDLE="/Applications/KA Window.app"
CONTENTS="$APP_BUNDLE/Contents"
MACOS="$CONTENTS/MacOS"
RESOURCES="$CONTENTS/Resources"

# Kill running instance
killall KAWindow 2>/dev/null || true

# Clean previous build
rm -rf "$APP_BUNDLE"

# Create app bundle structure
mkdir -p "$MACOS"
mkdir -p "$RESOURCES"

# Copy executable
cp .build/debug/KAWindow "$MACOS/KAWindow"

# Copy Info.plist
cp KAWindow/Info.plist "$CONTENTS/Info.plist"

# Create PkgInfo
echo "APPL????" > "$CONTENTS/PkgInfo"

# Ad-hoc code sign to stabilize accessibility permission
codesign --force --sign - "$APP_BUNDLE"

echo ""
echo "Build complete: $APP_BUNDLE"
echo "Run with: open \"$APP_BUNDLE\""
