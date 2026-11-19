# CI notes

Everything here is untested until the AWS box is up. Hosted Actions are fine
for lint and small kernel config checks; the full ROM build only makes sense
on the self-hosted runner.

## Layout
- `a16-ci` branch: workflows, tools, docs, manifests, host scripts, tests
- `a16-kernel`: kernel only — no CI files there

## Workflows
| file | runs on | what |
|------|---------|------|
| lint.yml | ubuntu-latest | shellcheck, py_compile, workflow_lint |

More workflows (kernel build, sync, rom) get added once the runner exists.
They'll all be `workflow_dispatch` only — no pull_request triggers, this repo
is public and a self-hosted runner would be a bad idea otherwise.

## Public runner risk
Anyone can fork a public repo. If a self-hosted runner is attached and someone
opens a PR, their code could run on your box. Mitigations:
- register the runner to this one repo only, not an org/user group
- workflows: `workflow_dispatch` + push to branches we own, never `pull_request`
- `permissions: contents: read`
- pin third-party actions to full commit SHAs (tests/workflow_lint.py checks this)
- keep the runner stopped when not building
- GitHub-hosted is free for public repos — prefer it for lint/small jobs

Repo setting to change by hand: Settings → Actions → General →
"Fork pull request workflows from outside collaborators" → require approval.

## Runner host
See `host/` for setup scripts (swap, packages, runner service). Untested.

## Buildkite (primary for Linux builds)

Pipeline: `.buildkite/pipeline.yml`  
Agent: Linux, 8 vCPU, 32 GB RAM, ~100 GB disk + cache volume (`/srv/ccache`, `/srv/kout`).  
Queue tag: `queue=linux`. Setup: `host/buildkite_agent.md`.

| Step | Command | Disk needed |
|------|---------|-------------|
| lint | `tests/run_lint.sh` | tiny |
| kernel | `.buildkite/build_kernel.sh` | ~5 GB |
| rom | `.buildkite/build_rom.sh` | **400 GB+ — disabled by default** |

GitHub Actions (`lint.yml`, `kernel.yml`) stay as a fallback / quick check.
The Buildkite kernel job uses the same config gate and refuses root configs.

### Why not ROM on 100 GB
Full LineageOS sync+build ≈ 250–350 GB. `build_rom.sh` exits early unless
`/srv/aosp` has ≥400 GB free and `BUILD_DISABLED` is unset.

### GitHub + Buildkite
Buildkite connects to GitHub directly (pipeline in-repo). GitHub Actions
remains for hosted lint if Buildkite is down. Do not use `pull_request`
triggers on either for self-hosted/agent execution.
