#!/usr/bin/env bash
# prepush_scan.sh — block pushes containing secrets/IMEI-like/firmware/oversize files
set -euo pipefail
MODE="${1:-staged}" # staged | range <old> <new>
fail=0
msg() { printf '%s\n' "$*" >&2; }

scan_blob() {
  local file="$1" content="$2"
  # patterns
  if printf '%s' "$content" | grep -qE 'ghp_[A-Za-z0-9]{20,}|github_pat_[A-Za-z0-9_]{20,}|AKIA[0-9A-Z]{16}|-----BEGIN (RSA |EC |OPENSSH )?PRIVATE KEY-----|password='; then
    msg "BLOCK secret-like content in $file"; fail=1
  fi
  # Luhn 15-digit IMEI-like
  if printf '%s' "$content" | grep -oE '[0-9]{15}' | while read -r n; do
      sum=0; alt=0
      for ((i=${#n}-1;i>=0;i--)); do
        d=${n:i:1}
        if ((alt)); then d=$((d*2)); ((d>9)) && d=$((d-9)); fi
        sum=$((sum+d)); alt=$((1-alt))
      done
      (( sum % 10 == 0 )) && exit 0
    done; then
    msg "BLOCK IMEI-like Luhn-valid 15-digit number in $file"; fail=1
  fi
  # serial RZ...
  if printf '%s' "$content" | grep -qE '\bRZ[A-Z0-9]{8,}\b'; then
    msg "BLOCK Samsung-serial-like RZ* in $file"; fail=1
  fi
}

scan_names() {
  local f="$1"
  local base
  base=$(basename "$f")
  case "$base" in
    *.zip|*.tar|*.md5|*.img|*.lz4|*.pit|*.rar|*.7z)
      # allow only under vendor proprietary paths if VENDOR_OK=1
      if [[ "${ALLOW_BLOBS:-0}" != "1" ]]; then
        msg "BLOCK firmware/image-like filename: $f"; fail=1
      fi
      ;;
    .env|credentials|*.pem|*.p12|*.keystore)
      msg "BLOCK credentials-like filename: $f"; fail=1
      ;;
  esac
  if [[ "$f" == *efs* || "$f" == *nvdata* || "$f" == *sec_efs* ]]; then
    msg "BLOCK EFS-related path: $f"; fail=1
  fi
}

scan_size() {
  local f="$1"
  if [[ -f "$f" ]]; then
    local sz
    sz=$(wc -c < "$f")
    if (( sz > 52428800 )); then
      msg "BLOCK file >50MB: $f ($sz bytes)"; fail=1
    fi
  fi
}

if [[ "$MODE" == "staged" ]]; then
  while IFS= read -r f; do
    [[ -z "$f" ]] && continue
    scan_names "$f"
    scan_size "$f"
    if git cat-file -e ":0:$f" 2>/dev/null; then
      content=$(git show ":0:$f" 2>/dev/null || true)
      scan_blob "$f" "$content"
    fi
  done < <(git diff --cached --name-only)
elif [[ "$MODE" == "range" ]]; then
  old="$2"; new="$3"
  while IFS= read -r f; do
    [[ -z "$f" ]] && continue
    scan_names "$f"
    if git cat-file -e "$new:$f" 2>/dev/null; then
      content=$(git show "$new:$f" 2>/dev/null || true)
      scan_blob "$f" "$content"
      scan_size /dev/null
      # size from blob
      sz=$(git cat-file -s "$new:$f" 2>/dev/null || echo 0)
      if (( sz > 52428800 )); then msg "BLOCK blob >50MB: $f"; fail=1; fi
    fi
  done < <(git diff --name-only "$old" "$new")
else
  msg "usage: prepush_scan.sh staged|range <old> <new>"; exit 2
fi

if (( fail )); then
  msg "prepush_scan: FAILED"
  exit 1
fi
msg "prepush_scan: OK"
exit 0
