#!/usr/bin/env bash
# Full LineageOS build. REFUSES unless /srv/aosp has ~400 GB free.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"

if [[ "${BUILD_DISABLED:-0}" == "1" ]]; then
  echo "BUILD_DISABLED=1 — ROM step turned off (100 GB agent is not enough)."
  echo "Attach a volume with 400GB+ at /srv/aosp and clear BUILD_DISABLED."
  exit 0
fi

AOSP="${AOSP_ROOT:-/srv/aosp}"
if [[ ! -d "$AOSP" ]]; then
  echo "missing $AOSP"; exit 1
fi
FREE_KB=$(df -Pk "$AOSP" | awk 'NR==2{print $4}')
FREE_GB=$((FREE_KB / 1024 / 1024))
echo "free on $AOSP: ${FREE_GB} GB"
if (( FREE_GB < 400 )); then
  echo "need >=400 GB free for sync+build, have ${FREE_GB} GB — aborting"
  exit 1
fi

export USE_CCACHE=1
[[ -d /srv/ccache ]] && export CCACHE_DIR=/srv/ccache

cd "$AOSP"
if [[ ! -d .repo ]]; then
  repo init -u https://github.com/LineageOS/android.git -b lineage-23.2 --depth=1
  mkdir -p .repo/local_manifests
  cp "$ROOT/manifests/a12s.xml" .repo/local_manifests/ 2>/dev/null || \
    cp "$ROOT/../manifests/a12s.xml" .repo/local_manifests/ 2>/dev/null || {
      echo "a12s.xml not found"; exit 1; }
fi
repo sync -c -j4 --no-tags --no-clone-bundle

source build/envsetup.sh
# verify lunch combo when this first runs on a real tree
breakfast a12s userdebug
m bacon -j6
echo "ROM build OK — find zip under out/target/product/a12s/"
