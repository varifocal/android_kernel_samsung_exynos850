#!/usr/bin/env bash
# Replace only the kernel inside an ORIGINAL boot.img; keep ramdisk/DTB/cmdline/header.
# UNTESTED ON DEVICE. Requires unpack_bootimg/mkbootimg (AOSP tools) on PATH.
# Usage: repack_boot.sh <orig_boot.img> <new_Image> <out_boot.img>
set -euo pipefail
ORIG="${1:-}"; KERNEL="${2:-}"; OUT="${3:-}"
[[ -f "$ORIG" && -f "$KERNEL" ]] || { echo "usage: $0 orig_boot.img Image out_boot.img"; exit 2; }
command -v unpack_bootimg >/dev/null || { echo "need unpack_bootimg (AOSP)"; exit 1; }
command -v mkbootimg >/dev/null || { echo "need mkbootimg (AOSP)"; exit 1; }
WORK=$(mktemp -d "${TMPDIR:-/tmp}/repack.XXXXXX" 2>/dev/null || mktemp -d)
trap 'rm -rf "$WORK"' EXIT
echo "unpack $ORIG"
unpack_bootimg --boot_img "$ORIG" --out "$WORK" >/dev/null
ls -la "$WORK"
# show what we keep
for f in ramdisk.img dtb.img dtbo.img second.img; do
  [[ -f "$WORK/$f" ]] && echo "keep $f ($(wc -c < "$WORK/$f") bytes)"
done
echo "kernel: $KERNEL ($(wc -c < "$KERNEL") bytes)  [Samsung SEANDROIDENFORCE footer: verify it survived]"
ARGS=( --boot_img "$ORIG" --kernel "$KERNEL" --output "$OUT" )
[[ -f "$WORK/ramdisk.img" ]] && ARGS+=( --ramdisk "$WORK/ramdisk.img" )
[[ -f "$WORK/dtb.img" ]] && ARGS+=( --dtb "$WORK/dtb.img" )
[[ -f "$WORK/header_version" ]] && ARGS+=( --header_version "$(cat "$WORK/header_version")" )
# many unpack_bootimg writes os_version/os_patch_level as files — pass through if present
[[ -f "$WORK/os_version" ]] && ARGS+=( --os_version "$(cat "$WORK/os_version")" )
[[ -f "$WORK/os_patch_level" ]] && ARGS+=( --os_patch_level "$(cat "$WORK/os_patch_level")" )
echo "mkbootimg ${ARGS[*]}"
mkbootimg "${ARGS[@]}"
echo "wrote $OUT ($(wc -c < "$OUT") bytes)"
# verify footer if strings available
if command -v strings >/dev/null; then
  if strings "$OUT" | grep -q SEANDROIDENFORCE; then
    echo "SEANDROIDENFORCE footer: present"
  else
    echo "WARNING: SEANDROIDENFORCE not found — Samsung bootloader may reject this image"
  fi
fi
sha256sum "$OUT"
echo "UNTESTED ON DEVICE — flash only via flash_boot.sh after rollback_manifest"
