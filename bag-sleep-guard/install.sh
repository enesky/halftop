#!/bin/zsh
set -eu

SRC_DIR="${0:A:h}"
SCRIPT_DIR="$HOME/Library/Scripts"
AGENT_DIR="$HOME/Library/LaunchAgents"
LABEL="com.eky.bag-sleep-guard"

mkdir -p "$SCRIPT_DIR" "$AGENT_DIR"
cp "$SRC_DIR/bag-sleep-guard.sh" "$SCRIPT_DIR/bag-sleep-guard.sh"
cp "$SRC_DIR/$LABEL.plist" "$AGENT_DIR/$LABEL.plist"
chmod +x "$SCRIPT_DIR/bag-sleep-guard.sh"

launchctl bootout "gui/$(id -u)" "$AGENT_DIR/$LABEL.plist" 2>/dev/null || true
launchctl bootstrap "gui/$(id -u)" "$AGENT_DIR/$LABEL.plist"
launchctl enable "gui/$(id -u)/$LABEL"

echo "Installed. Disable temporarily: touch ~/.bag-sleep-guard-off"
echo "Enable again: rm ~/.bag-sleep-guard-off"
