#!/bin/zsh
set -euo pipefail

LABEL="com.eky.halftop.sidescreen-login"
PLIST_FILE="$HOME/Library/LaunchAgents/$LABEL.plist"
ENABLED_FILE="$HOME/Library/Application Support/Halftop/Agents/.enabled/sidescreen-login"

/bin/launchctl bootout "gui/$(/usr/bin/id -u)" "$PLIST_FILE" 2>/dev/null || true
/bin/rm -f "$PLIST_FILE" "$ENABLED_FILE"

echo "Uninstalled."
