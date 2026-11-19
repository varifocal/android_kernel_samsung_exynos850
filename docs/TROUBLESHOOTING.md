# Troubleshooting

## Kernel CI
| Symptom | Likely cause | First look |
|---------|--------------|------------|
| `ld.lld: not found` | missing clang/lld on runner | apt install clang lld llvm (already in kernel.yml) |
| `no member ... mmap_sem` | Trustonic TEE on | `# CONFIG_TRUSTONIC_TEE is not set` |
| `no member usb_plug_status` | VBUS_NOTIFIER off | CONFIG_VBUS_NOTIFIER=y + drivers/samsung/misc |
| `No rule to make target gw3x_common.o` | fingerprint driver not in tree | drop CONFIG_SENSORS_GW3X |
| `undefined symbol: muic_afc_set_voltage` | MUIC core/HV off | MUIC_CORE + MUIC_HV + HV_MUIC_VOLTAGE_CTRL |
| `FileNotFound ... out/llvm-readelf` | FMP FIPS abspath | scripts/fmp/fips_fmp_integrity.py (fixed) |
| apt timeout on runner | GitHub mirror flake | re-run the workflow |

## First boot (when we get there)
| Symptom | First commands | Log to read |
|---------|----------------|-------------|
| Bootloop | reflash known-good boot via flash_boot.sh | pstore/last_kmsg after recovery boot |
| No touch | dmesg \| grep -i ili; ls /sys/class/input | dmesg ili9881x |
| No charge | dmesg \| grep -i sm5714; dumpsys battery | sm5714_charger logs |
| SIM gone | getprop gsm.sim.state; logcat -b radio | radio log + cp load |
| High drain | soak_logger overnight; dumpsys batterystats | wakelocks in batterystats |
| SELinux denials | dmesg \| grep avc; logcat -b events | avc: denied lines |

## ROM build (future runner)
| Symptom | First look |
|---------|------------|
| Soong/Kconfig error | exact make output; compare a21s lunch |
| vintf mismatch | checkvintf output; docs/vintf gap notes |
| breakfast unknown | lunch combo name for 23.2 — verify against LineageOS wiki |
