#!/usr/bin/env bash
# Pull pstore/last_kmsg — run from OrangeFox recovery with adb root. Read-only.
# UNTESTED ON DEVICE. Never writes to the phone.
set -euo pipefail
OUT="${1:-pstore_$(date +%Y%m%d_%H%M%S)}"
mkdir -p "$OUT"
adb root 2>/dev/null || true
adb shell "ls -la /sys/fs/pstore" > "$OUT/pstore_ls.txt" 2>&1 || true
adb pull /sys/fs/pstore "$OUT/pstore" 2>&1 || true
adb pull /proc/last_kmsg "$OUT/last_kmsg" 2>&1 || true
echo "saved under $OUT"
