#!/bin/zsh
set -eu

LABEL="com.eky.bag-sleep-guard"
AGENT="$HOME/Library/LaunchAgents/$LABEL.plist"

launchctl bootout "gui/$(id -u)" "$AGENT" 2>/dev/null || true
rm -f "$AGENT" "$HOME/Library/Scripts/bag-sleep-guard.sh"

echo "Uninstalled."
