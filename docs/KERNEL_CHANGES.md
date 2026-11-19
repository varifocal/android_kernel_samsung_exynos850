# a16-kernel changes vs LineageOS lineage-23.2 import

Branch: `a16-kernel` in varifocal/android_kernel_samsung_exynos850.
Base snapshot: LineageOS/android_kernel_samsung_exynos850@7995522e5 (4.19.325)
imported as 401f23e37 on top of android-14.0.

**Status: Image builds on GitHub-hosted Actions (run 44525325547). UNTESTED ON DEVICE.**

## Why this base
Official LineageOS ships Galaxy A21s (same Exynos 850) on lineage-23.2 with this
kernel. Proven path for Android 16 / LineageOS 23.2 on our SoC.

## What was added (a12s hardware the a21s tree doesn't carry)

| Area | Change | Source |
|------|--------|--------|
| DTS | `arch/arm64/boot/dts/samsung/a12s/*` DTBOs | android-14.0 (galaxym12) |
| Charger/FG | sm5714_charger, sm5714_fuelgauge | android-14.0 |
| MFD/MUIC/TypeC | drivers/{mfd,muic,usb/typec}/sm/sm5714 | android-14.0 |
| Touch | ili9881x driver | android-14.0 |
| Panels | nt36525b_{ctc,dtc,sharp}, td4150_boe, td4160/4375 a12s headers, ili9882q, ili7807s | android-14.0 |
| Defconfig | `exynos850-a12snsxx_defconfig` from old a12s (SM5714, not a21s S2MU106) | old a12s_defconfig |
| input.h | INPUT_FEATURE_ENABLE_SYSINPUT_ENABLED / PROX_LP_SCAN | android-14.0 |
| usb_notify | NOTIFY_EVENT_DR_SWAP | android-14.0 |
| usbpd_ops | usbpd_wait_entermode, usbpd_cc_control_command fields | android-14.0 |
| panel_drv | get_blic_type + blic_type= cmdline | android-14.0 |
| vbus_notifier | drivers/samsung/misc restored; SEC_MISC + VBUS_NOTIFIER on | android-14.0 |

## API adaptations (this tree ≠ android-14.0)

- **PDIC_PD30** Kconfig now depends on PDIC_NOTIFIER, not PDIC_SLSI_NON_MCU —
  sec_battery needs the PD30 POWER_LIST fields; SLSI usbpd core is S2MU-only.
- **usbpd_cc.c** stubs `pdic_event_work`/`typec_init` when no S2MU chip.
- **muic_notifier**: pdic statics under PDIC_NOTIFIER; `__maybe_unused` on
  leftovers; global `switch_device` defined (was extern-only).
- **sm5714 muic**: local OPMODE_* (can't include muic_interface.h — muic_irq_t
  clash); opmode on `sm5714_muic_data` not pdata; `muic_core_init()` for
  platform data; REQUEST_IRQ/FREE_IRQ undef before local 3-arg macros.
- **sm5714 typec**: cast port_type to typec_port_data for DFP/UFP compares.
- **sensorhub** subdirs gated on CONFIG_SENSORS_SSP (a12s has no SSP).
- **FMP FIPS script**: don't `abspath()` bare `llvm-readelf`.
- **ili9881x**: `-Wno-unused-but-set-variable` for that directory.

## Defconfig notes (a12s vs a21s)

On: SM5714 charger/fg/mfd/muic/pdic, ili9881x, A12S panels, MUIC_CORE/MANAGER/
SYSFS/HV, HV_MUIC_VOLTAGE_CTRL, ANDROID_VENDOR_HOOKS, SENSORS_ET5XX, PDIC_PD30,
PDIC_NOTIFIER, VBUS_NOTIFIER, SEC_MISC+ABC pieces.
Off: Trustonic TEE (mmap_sem), SCSC_WLBTD (undeclared ret), HDCP2 (strict-prototypes),
GW3X fingerprint (sources not in tree), S2MU106 (wrong PMIC), SLSI usbpd core.

## Still TODO before first boot
- Reconcile remaining defconfig deltas vs stock A127F full config (notes/defconfig_reconcile.md)
- Touch/panel firmware blobs (not in public tree — live under vendor or /vendor/firmware)
- Camera module framework bits beyond vendor_dt/a12s
- Real device test: boot, display, touch, charge, SIM (P12 runbook)
