#!/usr/bin/env bash
set -u

# Plays two short beeps after login, wake, or unlock.
# This script is intended to be kept alive by a LaunchAgent.
# Override LOGIN_BEEP_SOUND if you prefer another built-in sound.

SOUND_FILE="${LOGIN_BEEP_SOUND:-/System/Library/Sounds/Purr.aiff}"
BEEP_DURATION_SECONDS="${LOGIN_BEEP_DURATION_SECONDS:-0.07}"
POLL_SECONDS="${LOGIN_BEEP_POLL_SECONDS:-1}"
WAKE_GAP_SECONDS="${LOGIN_BEEP_WAKE_GAP_SECONDS:-8}"
MIN_BEEP_GAP_SECONDS="${LOGIN_BEEP_MIN_GAP_SECONDS:-2}"

log() {
  printf '%s\n' "$*" >&2
}

play_beep() {
  if [[ -r "$SOUND_FILE" ]]; then
    /usr/bin/afplay -t "$BEEP_DURATION_SECONDS" "$SOUND_FILE" >/dev/null 2>&1
  else
    printf '\a'
  fi
}

screen_locked() {
  local locked
  locked="$(/usr/sbin/ioreg -n Root -d1 2>/dev/null | /usr/bin/awk -F'= ' '/"IOConsoleLocked"/ {print $2; exit}')"
  case "$locked" in
    Yes|yes|true|1) return 0 ;;
    *) return 1 ;;
  esac
}

if [[ ! -x /usr/bin/afplay ]]; then
  log "Warning: /usr/bin/afplay not found or not executable; falling back to terminal bell."
fi

play_beep

last_check_epoch="$(/bin/date +%s)"
last_beep_epoch="$last_check_epoch"
was_locked=0
if screen_locked; then
  was_locked=1
fi

while true; do
  /bin/sleep "$POLL_SECONDS"

  now_epoch="$(/bin/date +%s)"
  elapsed=$((now_epoch - last_check_epoch))
  last_check_epoch="$now_epoch"

  is_locked=0
  if screen_locked; then
    is_locked=1
  fi

  should_beep=0

  if (( was_locked == 1 && is_locked == 0 )); then
    should_beep=1
  fi

  if (( elapsed >= WAKE_GAP_SECONDS && is_locked == 0 )); then
    should_beep=1
  fi

  if (( should_beep == 1 && now_epoch - last_beep_epoch >= MIN_BEEP_GAP_SECONDS )); then
    play_beep
    last_beep_epoch="$now_epoch"
  fi

  was_locked="$is_locked"
done
