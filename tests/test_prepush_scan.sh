#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SCAN="$ROOT/tools/prepush_scan.sh"
TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT
cd "$TMP"
git init -q
git config user.email t@t
git config user.name t
mkdir -p tools
cp "$SCAN" tools/prepush_scan.sh
chmod +x tools/prepush_scan.sh

# 1) clean file passes
echo hello > ok.txt
git add ok.txt
bash tools/prepush_scan.sh staged

# 2) fake token blocks
echo 'token ghp_abcdefghijklmnopqrstuvwxyz123456' > bad.txt
git add bad.txt
if bash tools/prepush_scan.sh staged; then echo "FAIL: token not blocked"; exit 1; else echo "PASS: token blocked"; fi
git reset -q bad.txt; rm bad.txt

# 3) IMEI-like Luhn (valid test number 490154203237518 is a classic test IMEI)
echo 'device 490154203237518' > imei.txt
git add imei.txt
if bash tools/prepush_scan.sh staged; then echo "FAIL: imei not blocked"; exit 1; else echo "PASS: imei blocked"; fi
git reset -q imei.txt; rm imei.txt

# 4) efs path blocks
mkdir -p dump
echo x > dump/efs.img
git add dump/efs.img
if bash tools/prepush_scan.sh staged; then echo "FAIL: efs path not blocked"; exit 1; else echo "PASS: efs blocked"; fi

echo "ALL PREPUSH TESTS PASSED"
