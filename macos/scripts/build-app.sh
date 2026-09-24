#!/usr/bin/env bash
# Build Wardrobe.app (release) dari Swift package ini.
# Hasil: build/Wardrobe.app dan build/Wardrobe.zip
set -euo pipefail

cd "$(dirname "$0")/.."

swift build -c release
BIN_DIR="$(swift build -c release --show-bin-path)"

APP="build/Wardrobe.app"
rm -rf "$APP" build/Wardrobe.zip
mkdir -p "$APP/Contents/MacOS" "$APP/Contents/Resources"

cp "$BIN_DIR/Wardrobe" "$APP/Contents/MacOS/Wardrobe"
cp Support/Info.plist "$APP/Contents/Info.plist"
# Resource dibaca lewat Bundle.main di dalam .app (lihat AppResources.swift).
cp Sources/Wardrobe/Resources/* "$APP/Contents/Resources/"

# Tanda tangan ad-hoc: cukup untuk dijalankan di Mac sendiri.
codesign --force --sign - "$APP"

ditto -c -k --keepParent "$APP" build/Wardrobe.zip
echo "Selesai: $APP"
