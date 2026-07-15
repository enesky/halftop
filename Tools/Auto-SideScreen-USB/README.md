# SideScreen Launch Tools

USB and WiFi SideScreen launch actions used by Halftop.

These scripts target the official SideScreen app. They set SideScreen's startup preferences, then open `com.sidescreen.app`.

## Requirements

- Official SideScreen from [GitHub Releases](https://github.com/tranvuongquocdat/SideScreen/releases/latest)
- Screen & System Audio Recording permission for SideScreen

## Entry points

```zsh
./SideScreen-usb.sh
./SideScreen-wireless.sh
./install-login.sh
./uninstall-login.sh
```

Halftop invokes these scripts directly from its application bundle. App Intents are the preferred shortcut integration.

The selected mode is written to SideScreen before launch:

```zsh
defaults write com.sidescreen.app SideScreen_autoStartStreamingOnLaunch -bool true
defaults write com.sidescreen.app SideScreen_startupMode -string usb
defaults write com.sidescreen.app SideScreen_connectionMode -string usb
```

`install-login.sh` installs `~/Library/LaunchAgents/com.eky.halftop.sidescreen-login.plist`, which opens the official SideScreen app after login. The selected startup mode remains whatever `SideScreen-usb.sh`, `SideScreen-wireless.sh`, or SideScreen itself last saved.
