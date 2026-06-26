#!/bin/zsh
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")" && pwd)"
SOURCE_FILE="$ROOT_DIR/Sources/HeadlessAutoResleep.swift"
BINARY_DIR="$ROOT_DIR/bin"
BINARY_FILE="$BINARY_DIR/HeadlessAutoResleep"
MODULE_CACHE="$ROOT_DIR/.clang-module-cache"
PLIST_FILE="$HOME/Library/LaunchAgents/com.eky.headless-auto-resleep.plist"
LABEL="com.eky.headless-auto-resleep"

/bin/mkdir -p "$BINARY_DIR" "$MODULE_CACHE" "$HOME/Library/LaunchAgents"
CLANG_MODULE_CACHE_PATH="$MODULE_CACHE" /usr/bin/swiftc "$SOURCE_FILE" -o "$BINARY_FILE"

/bin/cat > "$PLIST_FILE" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>$LABEL</string>
    <key>ProgramArguments</key>
    <array>
        <string>$BINARY_FILE</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
    <key>KeepAlive</key>
    <true/>
    <key>StandardOutPath</key>
    <string>/tmp/headless-auto-resleep.out.log</string>
    <key>StandardErrorPath</key>
    <string>/tmp/headless-auto-resleep.err.log</string>
</dict>
</plist>
PLIST

/bin/launchctl bootout "gui/$(id -u)" "$PLIST_FILE" 2>/dev/null || true
/bin/launchctl bootstrap "gui/$(id -u)" "$PLIST_FILE"
/bin/launchctl enable "gui/$(id -u)/$LABEL"

echo "Installed. Log: $HOME/Library/Logs/headless-auto-resleep.log"
