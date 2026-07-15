#!/bin/zsh
set -euo pipefail

LABEL="com.eky.halftop.sidescreen-login"
PLIST_FILE="$HOME/Library/LaunchAgents/$LABEL.plist"
ENABLED_DIR="$HOME/Library/Application Support/Halftop/Agents/.enabled"
APP="/Applications/SideScreen.app"
if [[ ! -d "$APP" ]]; then
  APP="$(/usr/bin/mdfind "kMDItemCFBundleIdentifier == 'com.sidescreen.app'" | /usr/bin/head -n 1 || true)"
fi
if [[ "$APP" == *"/.Trash/"* ]]; then
  APP=""
fi

if [[ ! -d "$APP" ]]; then
  echo "SideScreen is not installed. Install SideScreen: https://github.com/tranvuongquocdat/SideScreen/releases/latest"
  exit 69
fi

MINIMUM_VERSION="0.11.0"
version_at_least() {
  local current="$1"
  local minimum="$2"
  local IFS=.
  local -a current_parts minimum_parts
  current_parts=(${=current})
  minimum_parts=(${=minimum})
  for i in 1 2 3; do
    local current_part="${current_parts[$i]:-0}"
    local minimum_part="${minimum_parts[$i]:-0}"
    (( current_part > minimum_part )) && return 0
    (( current_part < minimum_part )) && return 1
  done
  return 0
}

version=$(/usr/libexec/PlistBuddy -c 'Print :CFBundleShortVersionString' "$APP/Contents/Info.plist" 2>/dev/null || true)
if [[ -z "$version" ]] || ! version_at_least "$version" "$MINIMUM_VERSION"; then
  echo "SideScreen $MINIMUM_VERSION or newer is required. Installed: ${version:-unknown}"
  exit 69
fi

/usr/bin/defaults write com.sidescreen.app SideScreen_autoStartStreamingOnLaunch -bool true
if ! /usr/bin/defaults read com.sidescreen.app SideScreen_startupMode >/dev/null 2>&1; then
  /usr/bin/defaults write com.sidescreen.app SideScreen_startupMode -string usb
fi

/bin/mkdir -p "$ENABLED_DIR" "$HOME/Library/LaunchAgents"
/bin/cat > "$PLIST_FILE" <<PLIST_XML
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>Label</key><string>$LABEL</string>
  <key>ProgramArguments</key><array><string>/usr/bin/open</string><string>-b</string><string>com.sidescreen.app</string></array>
  <key>RunAtLoad</key><true/>
  <key>StandardOutPath</key><string>/tmp/halftop-sidescreen-login.out.log</string>
  <key>StandardErrorPath</key><string>/tmp/halftop-sidescreen-login.err.log</string>
</dict>
</plist>
PLIST_XML

/bin/launchctl bootout "gui/$(/usr/bin/id -u)" "$PLIST_FILE" 2>/dev/null || true
/bin/launchctl bootstrap "gui/$(/usr/bin/id -u)" "$PLIST_FILE"
/bin/launchctl enable "gui/$(/usr/bin/id -u)/$LABEL"
: > "$ENABLED_DIR/sidescreen-login"

echo "Installed. SideScreen will open at login."
