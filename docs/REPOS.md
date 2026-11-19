# REPOS — varifocal (updated 2026-11-19)

## KEEP (never modify existing branches)
| Repo | Role | Branches (snapshot 2026-11-19) |
|------|------|--------------------------------|
| [android_kernel_samsung_exynos850](https://github.com/varifocal/android_kernel_samsung_exynos850) | **Kernel (only)** | `android-14.0`=`base-clean`=d9ec4ac28 (untouched); `suki`, `suki-build`, `susfs-nohooks`, `susfs-nohooks2` (untouched); **`a16-kernel`** = work branch (LineageOS 4.19.325 import) |
| [android_vendor_samsung](https://github.com/varifocal/android_vendor_samsung) | Vendor (galaxym12 fork) | `lineage-21`, `optimize` |
| [android_vendor_samsung_a12s](https://github.com/varifocal/android_vendor_samsung_a12s) | Vendor 23.2 extract (private) | `lineage-23.2` |

## FORKED from samsungexynos850 (build-upon set)
| Repo | Purpose |
|------|---------|
| [android_device_samsung_a21s](https://github.com/varifocal/android_device_samsung_a21s) | Sister device tree (pattern) |
| [android_device_samsung_a21s-common](https://github.com/varifocal/android_device_samsung_a21s-common) | SoC common (pattern) |
| [local_manifests](https://github.com/varifocal/local_manifests) | **+ `a12s.xml`** for our device |
| [android_build_scripts](https://github.com/varifocal/android_build_scripts) | `a21s.sh` lunch pattern |
| [scripts](https://github.com/varifocal/scripts) | Kernel backport helpers (gen_picks/pick/filter) |
| [manifest](https://github.com/varifocal/manifest) | Mainline/linux manifest (reference) |
| [tools](https://github.com/varifocal/tools) | AIK-Linux boot repack + mainline build.sh |
| [atlas](https://github.com/varifocal/atlas) | a21s custom kernel — **HAS KernelSU dir: READ-ONLY, never import root code** |
| [uniLoader](https://github.com/varifocal/uniLoader) | Secondary bootloader (mainline path reference) |

## CREATED (new, public)
| Repo | Branch | Notes |
|------|--------|-------|
| [android_device_samsung_a12s](https://github.com/varifocal/android_device_samsung_a12s) | `lineage-23.2` | Self-contained a12s tree from backup + a21s patterns; SELinux enforcing; AVB on; **UNTESTED ON DEVICE** |

## DELETED 2026-11-19 (local mirrors only: ~/work/backup-repos/)
- android_kernel_samsung_exynos850-clean, android_packages_apps_ims, android_device_samsung_m12-common, android_device_samsung_a12s-los21, android_device_samsung_a12s (old), android_hardware_interfaces

## USED AS-IS (no fork; via local manifest / lineage.dependencies)
LineageOS org @ lineage-23.2: `android_hardware_samsung`, `android_hardware_samsung_slsi_*`, `android_hardware_samsung_slsi-linaro_*`, `android_device_samsung_slsi_sepolicy`, `android_kernel_samsung_exynos850` (reference upstream).

## NOT FORKED (intentionally)
- firmware-samsung-a21s (firmware; not our device; privacy)
- linux, u-boot, CRB-Linux, pmos-lemonades, android_kernel_motorola_exynos9610, .github (org profile)
- Shorter name `android_kernel_samsung_exynos` does not exist (404)

## Local manifest
See `varifocal/local_manifests` branch `lineage-23.2` file **`a12s.xml`**:
device/samsung/a12s + vendor/samsung/a12s + kernel/samsung/exynos850@a16-kernel → varifocal;
hardware/slsi → LineageOS lineage-23.2.
