#!/usr/bin/env bash
# Build the exynos850 kernel (defconfig now; full Image when toolchain allows)
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
# when run from a16-ci branch, kernel may be checked out beside us or via input
KERNEL_DIR="${KERNEL_DIR:-$ROOT}"
OUT="${OUT:-$ROOT/out-kernel}"
DEFCONFIG="${DEFCONFIG:-exynos850-a12snsxx_defconfig}"
JOBS="${JOBS:-$(nproc 2>/dev/null || echo 4)}"

if [[ ! -f "$KERNEL_DIR/Makefile" ]]; then
  # try sibling checkout used by CI
  if [[ -f "$ROOT/../kernel/Makefile" ]]; then
    KERNEL_DIR="$(cd "$ROOT/../kernel" && pwd)"
  else
    echo "no kernel tree at $KERNEL_DIR — set KERNEL_DIR" >&2
    exit 1
  fi
fi

echo "kernel:  $KERNEL_DIR"
echo "out:     $OUT"
echo "config:  $DEFCONFIG"
echo "jobs:    $JOBS"
command -v clang >/dev/null && clang --version | head -1
command -v make >/dev/null && make --version | head -1

mkdir -p "$OUT"
make -C "$KERNEL_DIR" O="$OUT" ARCH=arm64 "$DEFCONFIG"
make -C "$KERNEL_DIR" O="$OUT" ARCH=arm64 olddefconfig

# gate if present
GATE="$ROOT/tools/check_config.py"
if [[ -f "$GATE" ]]; then
  python3 "$GATE" "$OUT/.config"
fi

# full image only if we have a working cross setup; try and don't lie
if make -C "$KERNEL_DIR" O="$OUT" ARCH=arm64 -j"$JOBS" Image; then
  echo "Image built: $OUT/arch/arm64/boot/Image"
  sha256sum "$OUT/arch/arm64/boot/Image"
else
  echo "Image build failed or toolchain incomplete — defconfig+gate only" >&2
  exit 1
fi
