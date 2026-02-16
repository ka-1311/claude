#!/bin/bash
set -e

echo "Building KA Pointer..."
swift build --product KAPointer

APP_BUNDLE="/Applications/KA Pointer.app"
CONTENTS="$APP_BUNDLE/Contents"
MACOS="$CONTENTS/MacOS"
RESOURCES="$CONTENTS/Resources"

# Kill running instance
killall KAPointer 2>/dev/null || true

# Clean previous build
rm -rf "$APP_BUNDLE"

# Create app bundle structure
mkdir -p "$MACOS"
mkdir -p "$RESOURCES"

# Copy executable
cp .build/debug/KAPointer "$MACOS/KAPointer"

# Copy Info.plist
cp KAPointer/Info.plist "$CONTENTS/Info.plist"

# Create PkgInfo
echo "APPL????" > "$CONTENTS/PkgInfo"

# Ad-hoc code sign to stabilize accessibility permission
codesign --force --sign - "$APP_BUNDLE"

echo ""
echo "Build complete: $APP_BUNDLE"
echo "Run with: open \"$APP_BUNDLE\""
