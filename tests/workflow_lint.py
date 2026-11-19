#!/usr/bin/env python3
"""Fail if workflows use forbidden triggers or unpinned third-party actions."""
from __future__ import annotations
import re
import sys
from pathlib import Path

FORBIDDEN_TRIGGERS = (
    "pull_request",
    "pull_request_target",
    "issue_comment",
    "workflow_run",
    "schedule",
    "repository_dispatch",
)
# allow actions/checkout etc pinned by major tag only for actions/* ; third-party must be full SHA
SHA_PIN = re.compile(r"uses:\s*([A-Za-z0-9_.-]+/[A-Za-z0-9_.-]+)@([0-9a-f]{40})\s*$")
TAG_OK = re.compile(r"uses:\s*(actions/[A-Za-z0-9_.-]+)@v\d+")
USES = re.compile(r"uses:\s*(\S+)")

def main() -> int:
    root = Path(__file__).resolve().parents[1]
    wf_dir = root / ".github" / "workflows"
    errors: list[str] = []
    if not wf_dir.is_dir():
        print("no workflows dir")
        return 0
    for path in sorted(wf_dir.glob("*.yml")) + sorted(wf_dir.glob("*.yaml")):
        text = path.read_text(encoding="utf-8")
        # naive trigger scan
        for t in FORBIDDEN_TRIGGERS:
            if re.search(rf"^\s*{t}\s*:", text, re.M):
                errors.append(f"{path.name}: forbidden trigger {t}")
        for m in USES.finditer(text):
            spec = m.group(1)
            if SHA_PIN.search(m.group(0).rstrip()) or TAG_OK.search(m.group(0).rstrip()):
                continue
            # full line check
            line = m.group(0)
            if re.search(r"@[0-9a-f]{40}\s*$", line):
                continue
            if re.search(r"uses:\s*actions/[^@\s]+@v\d+", line):
                continue
            if re.search(r"uses:\s*\$\{", line):
                continue  # expression — flag separately
            errors.append(f"{path.name}: unpinned action: {spec}")
    if errors:
        print("FAIL")
        for e in errors:
            print(" ", e)
        return 1
    print("OK: no forbidden triggers; actions pinned")
    return 0

if __name__ == "__main__":
    sys.exit(main())
