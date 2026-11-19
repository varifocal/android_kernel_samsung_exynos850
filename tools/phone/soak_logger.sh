#!/usr/bin/env bash
# Log battery/temp/uptime/wakeups/SIM to CSV every N seconds. Works without root.
# UNTESTED ON DEVICE. Usage: soak_logger.sh [interval_s] [hours] [outfile.csv]
set -euo pipefail
INTERVAL="${1:-60}"
HOURS="${2:-24}"
OUT="${3:-soak_$(date +%Y%m%d_%H%M%S).csv}"
command -v adb >/dev/null || { echo "no adb"; exit 1; }
adb get-state >/dev/null || { echo "device not in adb"; exit 1; }
END=$(( $(date +%s) + HOURS * 3600 ))
echo "ts,battery_pct,temp_c,uptime_s,sim_state,screen" > "$OUT"
echo "logging every ${INTERVAL}s for ${HOURS}h -> $OUT"
while [ "$(date +%s)" -lt "$END" ]; do
  ts=$(date -u +%Y-%m-%dT%H:%M:%SZ)
  bat=$(adb shell dumpsys battery 2>/dev/null | awk -F: '/level/{gsub(/ /,"",$2);print $2;exit}')
  temp=$(adb shell dumpsys battery 2>/dev/null | awk -F: '/temperature/{gsub(/ /,"",$2);print $2;exit}')
  up=$(adb shell cat /proc/uptime 2>/dev/null | awk '{print int($1)}')
  sim=$(adb shell getprop gsm.sim.state 2>/dev/null | tr -d '\r')
  scr=$(adb shell dumpsys power 2>/dev/null | awk -F= '/mWakefulness=/{print $2;exit}' | tr -d '\r')
  echo "$ts,$bat,$temp,$up,$sim,$scr" | tee -a "$OUT"
  sleep "$INTERVAL"
done
echo "done: $OUT"
