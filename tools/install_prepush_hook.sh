#!/usr/bin/env bash
# Install tools/prepush_scan.sh as a git pre-push hook in the current repo.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
HOOK="$(git rev-parse --git-dir)/hooks/pre-push"
cat > "$HOOK" <<'HOOK'
#!/usr/bin/env bash
set -euo pipefail
# read stdin: <local_ref> <local_sha> <remote_ref> <remote_sha>
while read -r lref lsha rref rsha; do
  [[ "$lsha" == 0000000000000000000000000000000000000000 ]] && continue
  base="$rsha"
  [[ "$base" == 0000000000000000000000000000000000000000 ]] && base=$(git merge-base "$lsha" HEAD 2>/dev/null || git rev-list --max-parents=0 "$lsha" | head -1)
  dir="$(cd "$(git rev-parse --show-toplevel)" && pwd)"
  if [ -f "$dir/tools/prepush_scan.sh" ]; then
    bash "$dir/tools/prepush_scan.sh" range "$base" "$lsha"
  fi
done
HOOK
chmod +x "$HOOK"
echo "installed $HOOK"
