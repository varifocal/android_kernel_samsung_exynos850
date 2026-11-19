#!/usr/bin/env bash
# Verify the rollback set exists and record checksums. READ-ONLY on files.
# UNTESTED. Usage: rollback_manifest.sh <dir-with-rollback-files>
set -euo pipefail
DIR="${1:-}"
[[ -n "$DIR" && -d "$DIR" ]] || { echo "usage: $0 <dir>"; exit 2; }
echo "=== rollback manifest $(date -u) ==="
echo "dir: $DIR"
need=0; have=0
for f in los21_rom.zip boot_good.img recovery_good.img; do
  # accept any matching pattern
  m=$(find "$DIR" -maxdepth 2 -type f -iname "*${f%.*}*" 2>/dev/null | head -1 || true)
  if [[ -n "$m" ]]; then
    sha=$(sha256sum "$m" | awk '{print $1}')
    sz=$(wc -c < "$m")
    echo "OK  $f -> $m sha256=$sha size=$sz"
    have=$((have+1))
  else
    echo "MISSING $f (looked for *${f%.*}*)"
    need=$((need+1))
  fi
done
# efs backups — presence only, never hash contents of identity data in logs beyond sha of file we don't read
if find "$DIR" -maxdepth 3 -iname '*efs*' 2>/dev/null | grep -q .; then
  echo "OK  efs backup present (not dumped here)"
else
  echo "WARN no efs backup in $DIR (you should have one from before any flash)"
fi
if (( need > 0 )); then
  echo "RESULT: incomplete ($need missing) — do NOT flash"
  exit 1
fi
echo "RESULT: complete ($have files) — still double-check hashes against your own record"
