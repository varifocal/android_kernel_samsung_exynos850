#!/usr/bin/env python3
"""Config gate: fail on missing hard requirements or root options."""
from __future__ import annotations
import sys
from pathlib import Path

# Hard requirements for Android 16 userspace on 4.19 (P3 provisional — update with P3 table)
REQUIRED = [
    "CONFIG_BPF_SYSCALL=y",
    "CONFIG_ANDROID_BINDER_IPC=y",
    "CONFIG_PSTORE=y",
    "CONFIG_PSTORE_RAM=y",
    "CONFIG_CGROUPS=y",
    "CONFIG_MEMCG=y",
    "CONFIG_EXT4_FS=y",
    "CONFIG_F2FS_FS=y",
    "CONFIG_ZRAM=y",
    "CONFIG_UNIX=y",
    "CONFIG_INET=y",
    "CONFIG_NETFILTER=y",
]
FORBIDDEN_SUBSTR = ("CONFIG_KSU", "CONFIG_KPM", "CONFIG_SUSFS", "CONFIGKSU")

def main() -> int:
    if len(sys.argv) != 2:
        print(f"usage: {sys.argv[0]} path/to/.config", file=sys.stderr)
        return 2
    path = Path(sys.argv[1])
    if not path.is_file():
        print(f"missing {path}", file=sys.stderr)
        return 2
    text = path.read_text(encoding="utf-8", errors="replace")
    lines = set(text.splitlines())
    errors = []
    for req in REQUIRED:
        if req not in lines:
            # allow =m for some?
            key = req.split("=")[0]
            if not any(l.startswith(key + "=") for l in lines):
                errors.append(f"missing hard requirement {req}")
    for line in lines:
        for bad in FORBIDDEN_SUBSTR:
            if line.startswith(bad) and not line.startswith("#"):
                # active (not commented) forbidden option
                if line.endswith("=y") or line.endswith("=m"):
                    errors.append(f"forbidden active option: {line}")
    # PSTORE must not be disabled
    if "# CONFIG_PSTORE is not set" in lines:
        errors.append("CONFIG_PSTORE disabled")
    if errors:
        print("CONFIG GATE FAIL")
        for e in errors:
            print(" -", e)
        return 1
    print("CONFIG GATE OK")
    return 0

if __name__ == "__main__":
    sys.exit(main())
