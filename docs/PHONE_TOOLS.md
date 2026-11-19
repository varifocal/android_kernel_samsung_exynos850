# Phone tools (`tools/phone/`)

All **UNTESTED ON DEVICE**. bash, `set -euo pipefail`, dry-run where they write.
Flash/dump paths refuse efs, sec_efs, nvdata, modem, param, sboot, lk, up_param,
keystorage and anything not on the allowlist.

| Script | What it does | Writes to phone? |
|--------|--------------|------------------|
| discover.sh | find adb/heimdall, print device state | no |
| baseline_collect.sh | getprop/dumpsys/logcat/dmesg + efs free space (not contents) | no |
| pstore_collect.sh | pull /sys/fs/pstore + last_kmsg (recovery) | no |
| soak_logger.sh | CSV battery/temp/uptime/SIM every N seconds | no |
| hw_checklist.sh | auto checks + manual prompts → report | no |
| jank_test.sh | swipes + dumpsys gfxinfo | input events only |
| dump_partition.sh | dd allowlisted partition twice, md5 compare | read-only |
| repack_boot.sh | new kernel into original boot.img, keep ramdisk/dtb/header | writes a file locally |
| flash_boot.sh | heimdall flash allowlisted part; DRY_RUN=1 default; type FLASH | **yes** (boot/recovery/vbmeta/dtbo) |
| rollback_manifest.sh | check LOS21 zip + boot + recovery present, sha256 | no |

`flash_rom_guide.md` — human steps for sideloading the ROM zip (see repo).
`pit_analyze.py` — read-only PIT parser + size budget (in progress).

## Safety rules (mission §6.5)
1. Allowlist only; protected names always refused.
2. Print partition + sha256 + rollback hint; confirmation word FLASH (boot: once per session).
3. Verify hash/size before send.
4. rollback_manifest must pass first.
5. Data wipe = separate extra confirmation (not automated here).
