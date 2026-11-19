#!/usr/bin/env bash
# Scripted scroll/launch jank probe via dumpsys gfxinfo. UNTESTED ON DEVICE.
set -euo pipefail
PKG="${1:-com.android.launcher3}"
OUT="${2:-jank_$(date +%Y%m%d_%H%M%S).txt}"
command -v adb >/dev/null || exit 1
{
  echo "=== jank test $(date -u) pkg=$PKG ==="
  adb shell am force-stop "$PKG" || true
  sleep 1
  adb shell am start -W "$PKG" || true
  sleep 3
  adb shell dumpsys gfxinfo "$PKG" reset || true
  # crude scroll: swipe up a few times
  for i in 1 2 3 4 5 6 7 8; do
    adb shell input swipe 500 1200 500 400 300
    sleep 0.3
  done
  sleep 1
  adb shell dumpsys gfxinfo "$PKG"
  echo "--- launch times (historical) ---"
  adb shell dumpsys activity activities | grep -A2 'Launch times' || true
} | tee "$OUT"
echo "saved $OUT"
