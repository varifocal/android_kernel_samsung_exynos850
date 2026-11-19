#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
python3 tests/workflow_lint.py
# Buildkite pipelines are YAML — basic sanity
python3 - <<'PY'
import sys
try:
    import yaml
except ImportError:
    print("pyyaml not installed; skipping pipeline parse")
    sys.exit(0)
from pathlib import Path
p = Path(".buildkite/pipeline.yml")
yaml.safe_load(p.read_text())
print("pipeline.yml parses OK")
PY
find tools -name '*.sh' -print0 | xargs -0 -r bash -n
find tools -name '*.py' -print0 | xargs -0 -r python3 -m py_compile
bash tests/test_prepush_scan.sh
# config gate if a stored config exists
for c in reports/kernel.config-* ../reports/kernel.config-*; do
  [ -f "$c" ] && python3 tools/check_config.py "$c"
done
echo "lint OK"
