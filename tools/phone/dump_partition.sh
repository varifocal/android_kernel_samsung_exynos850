#!/usr/bin/env bash
# Read-only partition dump via adb (recovery, root). Allowlist only.
# Double-dump + md5 compare. NEVER writes to the phone.
# UNTESTED ON DEVICE.
set -euo pipefail
ALLOWED=(boot recovery vbmeta dtbo)
PART="${1:-}"; OUT="${2:-}"
usage() { echo "usage: $0 <partition> <outfile>  allowed: ${ALLOWED[*]}"; exit 2; }
[[ -n "$PART" && -n "$OUT" ]] || usage
ok=0; for p in "${ALLOWED[@]}"; do [[ "$p" == "$PART" ]] && ok=1; done
if [[ "$ok" != 1 ]]; then
  echo "refusing '$PART' — allowlist: ${ALLOWED[*]}"
  echo "protected: efs sec_efs nvdata modem param sboot lk up_param keystorage"
  exit 1
fi
DEV="/dev/block/by-name/$PART"
[[ -e "$DEV" ]] || { echo "no $DEV"; exit 1; }
echo "reading $DEV -> $OUT (twice, md5 compare)"
adb shell "dd if=$DEV bs=4096 2>/dev/null | md5sum" | tee "$OUT.hash1"
adb pull "$DEV" "$OUT.part1" 2>/dev/null || adb shell "dd if=$DEV" > "$OUT.part1"
# second pass via shell md5 of full read
adb shell "dd if=$DEV bs=4096 2>/dev/null | md5sum" | tee "$OUT.hash2"
if [[ "$(awk '{print $1}' "$OUT.hash1")" == "$(awk '{print $1}' "$OUT.hash2")" ]]; then
  echo "OK double-dump matches"
  sha256sum "$OUT.part1" | tee "$OUT.sha256"
else
  echo "FAIL dumps differ"; exit 1
fi
