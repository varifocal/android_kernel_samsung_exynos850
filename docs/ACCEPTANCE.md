# Acceptance test sheet (from mission §15)

All rows **UNTESTED ON DEVICE** until the phone is connected. Record date, ROM
build, kernel sha, and pass/fail.

## Boot / stability
| # | Test | Command / method | Pass criteria | Result |
|---|------|------------------|---------------|--------|
| 1 | Cold boot ×10 | power off → on | 10/10 reach lockscreen | |
| 2 | 72h soak | soak_logger.sh 72h | 0 unexpected reboots; pstore clean | |
| 3 | pstore | pstore_collect.sh after any reboot | no oops/warn in last_kmsg | |

## Hardware
| # | Test | Method | Pass | Result |
|---|------|--------|------|--------|
| 4 | Display/brightness | hw_checklist.sh + manual | normal range, no flicker | |
| 5 | Touch 1h | hw_checklist + use | 0 dropouts | |
| 6 | Audio SP/mic/headset/call | hw_checklist | all work | |
| 7 | SIM/data/SMS/VoLTE | soak_logger + manual | no dropout in logs | |
| 8 | Wi-Fi/BT/GPS | hw_checklist | associate, pair, fix | |
| 9 | Camera front/rear/flash | hw_checklist | preview+capture | |
| 10 | Sensors | hw_checklist | accel/gyro/prox present | |
| 11 | Vibrator | hw_checklist | buzz | |
| 12 | Charging | soak_logger | % climbs; no heat runaway | |
| 13 | USB/adb/MTP | discover.sh + manual | works | |
| 14 | Suspend/resake | manual + dmesg | resumes; no wakelock storm | |

## Software
| # | Test | Method | Pass | Result |
|---|------|--------|------|--------|
| 15 | SELinux | getenforce | Enforcing; no core avc denials | |
| 16 | VINTF | logcat + checkvintf if available | compatibility OK | |
| 17 | Jank scroll | jank_test.sh | janky frames < ~10% | |
| 18 | Launch times | jank_test.sh | recorded vs LOS21 baseline | |
| 19 | 72h ANR/crash | logcat -b events | 0 system_server crashes | |
| 20 | Idle drain | overnight airplane on/off vs baseline | ≤ baseline %/h | |

Anything below target: list cause + options in the report.
