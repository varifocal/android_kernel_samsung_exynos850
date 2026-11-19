#!/usr/bin/env bash
# Find a working adb/heimdall on this machine. Read-only.
set -euo pipefail
echo "adb:   $(command -v adb || echo missing)"
echo "heimdall: $(command -v heimdall || echo missing)"
if command -v adb >/dev/null; then
  adb start-server 2>/dev/null || true
  adb devices -l || true
fi
if [[ -d /dev/bus/usb ]] && command -v termux-usb >/dev/null; then
  echo "termux-usb present; ls /dev/bus/usb for devices"
fi
echo "(phone not required for this phase)"
