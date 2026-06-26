#!/bin/zsh
set -euo pipefail

PLIST_FILE="$HOME/Library/LaunchAgents/com.eky.lock-screen-sayer.plist"

/bin/launchctl bootout "gui/$(id -u)" "$PLIST_FILE" 2>/dev/null || true
/bin/rm -f "$PLIST_FILE"

echo "Uninstalled."
