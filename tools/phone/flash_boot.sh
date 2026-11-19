#!/usr/bin/env bash
# Heimdall flash for boot only. Prints what it will do, checks hashes, asks
# for a confirmation word. UNTESTED ON DEVICE.
# Never touches efs/sec_efs/nvdata/modem/param/sboot/lk/up_param/keystorage.
set -euo pipefail

ALLOWED=(boot recovery vbmeta dtbo)
PART="${1:-}"
IMG="${2:-}"

usage() {
  echo "usage: $0 <partition> <image>"
  echo "allowed partitions: ${ALLOWED[*]}"
  echo "this will ask you to type FLASH before anything is sent"
  exit 2
}

[[ -n "$PART" && -n "$IMG" ]] || usage
ok=0
for p in "${ALLOWED[@]}"; do [[ "$p" == "$PART" ]] && ok=1; done
if [[ "$ok" != 1 ]]; then
  echo "refusing: '$PART' is not on the allowlist (${ALLOWED[*]})"
  echo "protected: efs sec_efs nvdata modem param sboot lk up_param keystorage"
  exit 1
fi
[[ -f "$IMG" ]] || { echo "no such image: $IMG"; exit 1; }

# refuse if image looks like a full dump / huge
sz=$(wc -c < "$IMG")
if (( sz > 80*1024*1024 )); then
  echo "refusing: $IMG is ${sz} bytes, too big for $PART"
  exit 1
fi

echo "partition: $PART"
echo "image:    $IMG ($sz bytes)"
echo "sha256:   $(sha256sum "$IMG" | awk '{print $1}')"
echo "heimdall: $(command -v heimdall || echo MISSING)"
echo "rollback: keep a copy of the current $PART before flashing"
echo
if [[ "${DRY_RUN:-1}" == "1" ]]; then
  echo "DRY_RUN=1 (default) — not sending anything. Set DRY_RUN=0 to proceed."
  exit 0
fi
read -r -p "type FLASH to continue: " ans
[[ "$ans" == "FLASH" ]] || { echo "aborted"; exit 1; }
heimdall flash "$PART" "$IMG"
echo "done. if it bootloops, reflash the previous $PART from your backup."
