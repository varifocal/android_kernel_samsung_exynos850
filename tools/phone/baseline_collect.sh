#!/usr/bin/env bash
# Read-only baseline from a phone that already boots (LOS21). No writes.
# UNTESTED ON DEVICE.
set -euo pipefail
OUT="${1:-baseline_$(date +%Y%m%d_%H%M%S)}"
mkdir -p "$OUT"
echo "collecting into $OUT (read-only)"
command -v adb >/dev/null || { echo "no adb"; exit 1; }
adb get-state >/dev/null || { echo "device not in adb"; exit 1; }

adb shell getprop > "$OUT/getprop.txt" 2>&1 || true
adb shell dumpsys battery > "$OUT/battery.txt" 2>&1 || true
adb shell dumpsys power > "$OUT/power.txt" 2>&1 || true
adb shell dumpsys deviceidle > "$OUT/deviceidle.txt" 2>&1 || true
adb shell dumpsys telephony.registry > "$OUT/telephony.txt" 2>&1 || true
adb shell "cat /sys/class/power_supply/*/uevent" > "$OUT/power_supply.txt" 2>&1 || true
adb shell "ls /sys/class/thermal" > "$OUT/thermal_zones.txt" 2>&1 || true
adb shell dmesg > "$OUT/dmesg.txt" 2>&1 || true
adb logcat -d -b all > "$OUT/logcat_all.txt" 2>&1 || true
adb shell "df /efs /mnt/vendor/efs 2>/dev/null; df -h" > "$OUT/efs_free_space.txt" 2>&1 || true
# free space only — never cat efs contents
adb shell "cat /proc/sys/kernel/boot_reason" > "$OUT/boot_reason.txt" 2>&1 || true
echo done
ls -la "$OUT"
