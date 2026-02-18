#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "${ROOT_DIR}"

echo "Local Dictation Launcher"
echo
scripts/dictation list-devices
echo

read -rp "Choose device index (default: 0): " DEVICE
read -rp "Session name (default: meeting-$(date +%Y%m%d-%H%M%S)): " SESSION_NAME
read -rp "Optional timer in minutes (blank = manual stop): " DURATION_MIN

if [ -z "${SESSION_NAME}" ]; then
  SESSION_NAME="meeting-$(date +%Y%m%d-%H%M%S)"
fi

if [ -z "${DEVICE}" ]; then
  DEVICE="0"
fi

if [ -n "${DURATION_MIN}" ]; then
  DURATION_SEC="$((DURATION_MIN * 60))"
  echo
  echo "Recording will auto-stop after ${DURATION_MIN} minute(s)."
  scripts/dictation meeting --device "${DEVICE}" --duration "${DURATION_SEC}" --name "${SESSION_NAME}" --lang en
else
  echo
  echo "Recording is manual with live controls: p=pause, r=resume, s=stop."
  scripts/dictation meeting --device "${DEVICE}" --name "${SESSION_NAME}" --lang en
fi

echo
echo "Done. Files are in: sessions/${SESSION_NAME}/"
read -rp "Press Enter to close..."
