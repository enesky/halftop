#!/bin/bash
set -euo pipefail

# Usage:
#   SideScreen.sh usb
#   SideScreen.sh wireless

mode="${1:-usb}"
case "$mode" in
    usb|wired|cable|kablolu)
        mode="usb"
        ;;
    wireless|wifi|kablosuz)
        mode="wireless"
        ;;
    *)
        echo "Usage: $0 usb|wireless" >&2
        exit 64
        ;;
esac

app="/Applications/SideScreen.app"
if [[ ! -d "$app" ]]; then
    app="$(/usr/bin/mdfind "kMDItemCFBundleIdentifier == 'com.sidescreen.app'" | /usr/bin/head -n 1 || true)"
fi
if [[ "$app" == *"/.Trash/"* ]]; then
    app=""
fi

if [[ ! -d "$app" ]]; then
    echo "SideScreen is not installed. Install SideScreen:"
    echo "https://github.com/tranvuongquocdat/SideScreen/releases/latest"
    exit 69
fi

minimum_version="0.11.0"
version_at_least() {
    local current="$1"
    local minimum="$2"
    local IFS=.
    local current_parts minimum_parts
    read -r -a current_parts <<< "$current"
    read -r -a minimum_parts <<< "$minimum"
    for i in 0 1 2; do
        local current_part="${current_parts[$i]:-0}"
        local minimum_part="${minimum_parts[$i]:-0}"
        if (( current_part > minimum_part )); then return 0; fi
        if (( current_part < minimum_part )); then return 1; fi
    done
    return 0
}

version=$(/usr/libexec/PlistBuddy -c 'Print :CFBundleShortVersionString' "$app/Contents/Info.plist" 2>/dev/null || true)
if [[ -z "$version" ]] || ! version_at_least "$version" "$minimum_version"; then
    echo "SideScreen $minimum_version or newer is required. Installed: ${version:-unknown}"
    echo "https://github.com/tranvuongquocdat/SideScreen/releases/latest"
    exit 69
fi

/usr/bin/defaults write com.sidescreen.app SideScreen_autoStartStreamingOnLaunch -bool true
/usr/bin/defaults write com.sidescreen.app SideScreen_startupMode -string "$mode"
/usr/bin/defaults write com.sidescreen.app SideScreen_connectionMode -string "$mode"

if /usr/bin/pgrep -x SideScreen >/dev/null 2>&1; then
    /usr/bin/osascript -e 'tell application id "com.sidescreen.app" to quit' >/dev/null 2>&1 || true
    for _ in {1..30}; do
        /usr/bin/pgrep -x SideScreen >/dev/null 2>&1 || break
        /bin/sleep 0.1
    done
    /usr/bin/pkill -x SideScreen >/dev/null 2>&1 || true
fi

/usr/bin/open -b com.sidescreen.app
