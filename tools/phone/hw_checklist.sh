#!/usr/bin/env bash
# Guided hardware checklist. Auto-checks what adb can see, prompts for the rest.
# UNTESTED ON DEVICE. Usage: hw_checklist.sh [report_dir]
set -euo pipefail
OUT="${1:-hw_$(date +%Y%m%d_%H%M%S)}"
mkdir -p "$OUT"
command -v adb >/dev/null || { echo "no adb"; exit 1; }
adb get-state >/dev/null || { echo "not in adb"; exit 1; }
R="$OUT/report.txt"
: > "$R"
say() { echo "$*" | tee -a "$R"; }
chk() { # name cmd
  local n="$1"; shift
  if "$@" >/dev/null 2>&1; then say "PASS $n"; else say "FAIL $n"; fi
}

say "=== hw checklist $(date -u) ==="
say "device: $(adb shell getprop ro.product.model | tr -d '\r')"
say "build:  $(adb shell getprop ro.build.display.id | tr -d '\r')"

# auto
chk "adb alive" adb shell true
chk "battery service" adb shell dumpsys battery
chk "power service" adb shell dumpsys power
chk "telephony" adb shell dumpsys telephony.registry
chk "wifi" adb shell dumpsys wifi
chk "bluetooth" adb shell dumpsys bluetooth_manager
chk "sensorservice" adb shell dumpsys sensorservice
chk "camera" adb shell dumpsys media.camera
chk "display" adb shell dumpsys display
chk "input (touch)" adb shell dumpsys input
chk "power_supply nodes" adb shell ls /sys/class/power_supply
chk "thermal zones" adb shell ls /sys/class/thermal
chk "bootreason" adb shell cat /proc/sys/kernel/boot_reason

# manual prompts
for m in \
  "Display: brightness min/max normal? (y/n)" \
  "Touch: draw lines, no dead spots? (y/n)" \
  "Speaker + mic + wired headset audio? (y/n)" \
  "Voice call connects? (y/n)" \
  "Wi-Fi associates + gets IP? (y/n)" \
  "Bluetooth pairs with something? (y/n)" \
  "GPS gets a fix outdoors? (y/n)" \
  "Rear camera + front camera + flash? (y/n)" \
  "Vibrator buzzes? (y/n)" \
  "Charger starts charging? (y/n)" \
  "USB adb + MTP? (y/n)"
 do
  read -r -p "$m " a || a=n
  echo "MANUAL $m -> $a" | tee -a "$R"
done
echo "report: $R"
