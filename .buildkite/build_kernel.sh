#!/usr/bin/env bash
# Kernel build on the Buildkite Linux agent (8c/32G).
# Uses /srv/kout + /srv/ccache when present so rebuilds are incremental.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

# --- locate kernel: env, sibling checkout, or clone a16-kernel ---
KERNEL_DIR="${KERNEL_DIR:-}"
if [[ -z "$KERNEL_DIR" ]]; then
  if [[ -d "$ROOT/kernel" && -f "$ROOT/kernel/Makefile" ]]; then
    KERNEL_DIR="$ROOT/kernel"
  elif [[ -d "$ROOT/../kernel" && -f "$ROOT/../kernel/Makefile" ]]; then
    KERNEL_DIR="$(cd "$ROOT/../kernel" && pwd)"
  else
    echo "cloning a16-kernel (depth 1)..."
    KERNEL_DIR="$ROOT/kernel"
    git clone --depth 1 --branch a16-kernel \
      https://github.com/varifocal/android_kernel_samsung_exynos850.git \
      "$KERNEL_DIR"
  fi
fi

DEFCONFIG="${DEFCONFIG:-exynos850-a12snsxx_defconfig}"
# 8 vCPU / 32 GB: -j6 leaves headroom for ld.lld
JOBS="${JOBS:-6}"

# out dir: prefer persistent volume
if [[ -d /srv/kout ]]; then
  OUT=/srv/kout
elif [[ -d /srv/cache/kout ]]; then
  OUT=/srv/cache/kout
else
  OUT="$ROOT/kout"
fi
mkdir -p "$OUT"

# ccache
if [[ -d /srv/ccache ]]; then
  export CCACHE_DIR=/srv/ccache
elif [[ -d /srv/cache/ccache ]]; then
  export CCACHE_DIR=/srv/cache/ccache
fi
command -v ccache >/dev/null && export USE_CCACHE=1 CCACHE_EXEC="$(command -v ccache)"

echo "kernel:  $KERNEL_DIR"
echo "out:     $OUT"
echo "jobs:    $JOBS"
echo "ccache:  ${CCACHE_DIR:-disabled}"
echo "disk:    $(df -h "$OUT" | tail -1)"
clang --version | head -1
make --version | head -1

LOG="$ROOT/kernel-build.log"
{
  make -C "$KERNEL_DIR" O="$OUT" ARCH=arm64 "$DEFCONFIG"
  make -C "$KERNEL_DIR" O="$OUT" ARCH=arm64 olddefconfig
  python3 "$ROOT/tools/check_config.py" "$OUT/.config"
  make -C "$KERNEL_DIR" O="$OUT" ARCH=arm64 CC=clang LLVM=1 LLVM_IAS=1 \
    CROSS_COMPILE=aarch64-linux-gnu- -j"$JOBS" Image
} 2>&1 | tee "$LOG"

sha256sum "$OUT/arch/arm64/boot/Image"
cp "$OUT/.config" "$ROOT/kernel.config" 2>/dev/null || true
# artifacts are relative to checkout — copy Image into workspace
mkdir -p "$ROOT/kout/arch/arm64/boot"
cp "$OUT/arch/arm64/boot/Image" "$ROOT/kout/arch/arm64/boot/Image"
cp "$OUT/.config" "$ROOT/kout/.config"
echo "kernel build OK"
