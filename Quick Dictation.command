#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "${ROOT_DIR}"

# Safety cap for recording length in minutes (default: 480 = 8 hours).
# Override per run: DICTATION_MAX_MINUTES=360 dictation
MAX_DURATION_MIN="${DICTATION_MAX_MINUTES:-480}"

echo "Local Dictation Launcher"
echo
scripts/dictation list-devices
echo

read -rp "Choose device index (default: 0): " DEVICE
read -rp "Session name (default: meeting-$(date +%Y%m%d-%H%M%S)): " SESSION_NAME
read -rp "Optional timer in minutes (blank = manual stop, max ${MAX_DURATION_MIN}): " DURATION_MIN

if [ -z "${SESSION_NAME}" ]; then
  SESSION_NAME="meeting-$(date +%Y%m%d-%H%M%S)"
fi

if [ -z "${DEVICE}" ]; then
  DEVICE="0"
fi

if ! [[ "${MAX_DURATION_MIN}" =~ ^[0-9]+$ ]] || [ "${MAX_DURATION_MIN}" -le 0 ]; then
  echo "Invalid DICTATION_MAX_MINUTES='${MAX_DURATION_MIN}'. Must be a positive integer." >&2
  exit 1
fi

if [ -n "${DURATION_MIN}" ]; then
  if ! [[ "${DURATION_MIN}" =~ ^[0-9]+$ ]] || [ "${DURATION_MIN}" -le 0 ]; then
    echo "Timer must be a positive number of minutes." >&2
    exit 1
  fi
  if [ "${DURATION_MIN}" -gt "${MAX_DURATION_MIN}" ]; then
    DURATION_MIN="${MAX_DURATION_MIN}"
  fi
  DURATION_SEC="$((DURATION_MIN * 60))"
  echo
  echo "Recording will auto-stop after ${DURATION_MIN} minute(s)."
  caffeinate -dimsu scripts/dictation meeting --device "${DEVICE}" --duration "${DURATION_SEC}" --name "${SESSION_NAME}" --lang en
else
  DURATION_SEC="$((MAX_DURATION_MIN * 60))"
  echo
  echo "Recording is manual with live controls: p=pause, r=resume, s=stop."
  echo "Safety cap is ${MAX_DURATION_MIN} minute(s), then auto-stop."
  caffeinate -dimsu scripts/dictation meeting --device "${DEVICE}" --duration "${DURATION_SEC}" --name "${SESSION_NAME}" --lang en
fi

echo
echo "Done. Files are in: sessions/${SESSION_NAME}/"
read -rp "Press Enter to close..."
