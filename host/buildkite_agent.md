# Buildkite Linux agent (8 vCPU / 32 GB / ~100 GB + cache volume)

## What it can run
| Job | Fits in 100 GB? | Notes |
|-----|-----------------|-------|
| lint | yes | seconds |
| kernel Image | yes | ~1–2 GB tree + kout |
| full ROM sync+bacon | **no** | needs 400 GB+ at `/srv/aosp` |

Cache volume should provide: `/srv/ccache`, `/srv/kout` (and `/srv/aosp` when big enough).

## Install (Ubuntu)
```bash
curl -fsSL https://packagecloud.io/buildkite/agent/gpg.key | sudo gpg --dearmor -o /usr/share/keyrings/buildkite-agent.gpg
echo "deb [signed-by=/usr/share/keyrings/buildkite-agent.gpg] https://packagecloud.io/buildkite/agent/any/ any main" | \
  sudo tee /etc/apt/sources.list.d/buildkite-agent.list
sudo apt-get update && sudo apt-get install -y buildkite-agent

# token: Buildkite UI → Agents → New agent (or org settings)
sudo nano /etc/buildkite-agent/buildkite-agent.cfg
#   token="xxxx"
#   tags="queue=linux,os=linux,arch=x64"
#   name="%hostname-%pid"

sudo systemctl enable --now buildkite-agent
```

## Packages for builds
```bash
sudo xargs -a "$(dirname "$0")/packages.txt" apt-get install -y
# plus: clang lld llvm repo git-lfs openjdk-17-jdk
```

## Connect repo
1. Buildkite → New pipeline → connect GitHub `varifocal/android_kernel_samsung_exynos850`
2. Path to pipeline: `.buildkite/pipeline.yml`
3. Source: Git repository (default branch `a16-ci`)
4. Trigger: manual + push to `a16-ci` (not PRs from forks)

## Security
- Agent token is a secret on the box only — never commit it
- Tags must include `queue=linux` to match pipeline
- One agent per box; stop when idle (systemctl stop buildkite-agent)
- No inbound ports beyond what Buildkite needs outbound HTTPS

## First runs
1. Push pipeline, hit “Run” on **lint** — should go green in <1 min
2. Run **kernel** — expect 10–20 min first time, faster with /srv/kout
3. Leave **rom** disabled until a 400 GB volume is at /srv/aosp
