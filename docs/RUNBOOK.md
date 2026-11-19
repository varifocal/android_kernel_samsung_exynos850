# Runbook — SM-A127F LineageOS 23.2

Everything below is **UNTESTED ON DEVICE / UNTESTED ON RUNNER** until you follow it
with real hardware. Order matters.

## 0. What already works (statically)
- `a16-kernel` Image builds on GitHub-hosted Actions (~12–17 min).
- Config gate green; no root options; PSTORE on; SM5714 + ili9881x + A12S panels on.
- Device tree `varifocal/android_device_samsung_a12s` branch `lineage-23.2` exists.
- Local manifest `varifocal/local_manifests` file `a12s.xml`.

## 1. AWS runner (when you're ready — not this phase)
- Create instance, swap, packages: see `host/packages.txt` + `host/README.md` (UNTESTED).
- Register runner to **this kernel repo only**, label `a12s-build`.
- Workflows are `workflow_dispatch` only. Keep the runner off when idle.

## 2. Kernel (works today on hosted)
```
gh workflow run kernel.yml -R varifocal/android_kernel_samsung_exynos850 \
  -f ref=a16-kernel -f defconfig=exynos850-a12snsxx_defconfig
gh run watch   # ~15 min
# download artifact kernel-a16-kernel → Image + .config + build.log
```
Expected: success, Image ~33 MB. Send back: run URL + sha256 of Image.

## 3. Full ROM (needs runner + disk)
```
# on the build box, after repo sync with manifests/a12s.xml in .repo/local_manifests/
source build/envsetup.sh
breakfast a12s userdebug     # verify exact combo for 23.2 when you get there
m bacon -j$(nproc)           # or mka bacon — verify
```
Estimates: sync 30–90 min first time; build 45–120 min on 8 vCPU. UNTESTED.

## 4. Phone baseline (current LOS21, before any flash)
```
tools/phone/discover.sh
tools/phone/baseline_collect.sh baseline_$(date +%Y%m%d)
tools/phone/soak_logger.sh &   # 12–72 h if you can leave it
```
Keep the output folder. This is the drain/crash baseline.

## 5. New kernel on old ROM (boot only)
- Repack boot with `tools/phone/repack_boot.sh` (replace kernel only).
- Flash with `tools/phone/flash_boot.sh boot boot.img` (DRY_RUN=1 default).
- 10 cold boots. If it doesn't boot, reflash previous boot from rollback set.

## 6. Full ROM flash
- `tools/phone/rollback_manifest.sh` first — must have LOS21 zip + boot + recovery.
- Follow `tools/phone/flash_rom_guide.md` (sideload in OrangeFox).
- Never flash efs/sec_efs/nvdata/modem/sboot (scripts refuse).

## 7. Test
- Work through `docs/ACCEPTANCE.md`.
- Collect AVCs: `tools/phone/` + `dmesg` / `logcat -b events`.

## 8. Rollback
- Reflash LineageOS 21 zip + known-good boot/recovery from the manifest.
- If boot is dead: heimdall flash original boot (allowlisted in flash_boot.sh).

## What to send back if something fails
- Workflow run URL, or
- Exact command + last 50 lines of log, or
- Which ACCEPTANCE row failed + logcat/dmesg snippet.
