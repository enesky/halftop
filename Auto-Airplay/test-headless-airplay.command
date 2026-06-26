#!/usr/bin/env bash
set -u

# Double-clickable test shortcut for the headless AirPlay setup.

SCRIPTS_DIR="${SCRIPTS_DIR:-$HOME/scripts}"
LOGIN_BEEP_SCRIPT="$SCRIPTS_DIR/login-beep.sh"
RUN_AIRPLAY_SCRIPT="$SCRIPTS_DIR/run-airplay.sh"

clear
echo "Headless AirPlay test shortcut"
echo
echo "1) Test login bip-bip"
echo "2) Test AirPlay bip-bip-bip only"
echo "3) Preflight: repo and script permission checks"
echo "4) Full AirPlay flow"
echo
printf "Choose 1-4: "
read -r choice
echo

case "$choice" in
  1)
    exec /bin/bash "$LOGIN_BEEP_SCRIPT"
    ;;
  2)
    exec /bin/bash "$RUN_AIRPLAY_SCRIPT" --beep-only
    ;;
  3)
    exec /bin/bash "$RUN_AIRPLAY_SCRIPT" --preflight
    ;;
  4)
    exec /bin/bash "$RUN_AIRPLAY_SCRIPT"
    ;;
  *)
    echo "Invalid choice: $choice"
    exit 1
    ;;
esac

