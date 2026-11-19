# Build host (AWS)

Untested. Believed box: r6a.2xlarge-ish, Ubuntu, ~970G disk.

1. create swapfile (32G) — no swap on the instance as specced
2. `xargs -a packages.txt apt install -y` (needs sudo)
3. install `repo` to ~/bin
4. ccache on a big disk path, e.g. /srv/ccache
5. create non-root user for the Actions runner, label `a12s-build`
6. register runner against varifocal/android_kernel_samsung_exynos850 only
7. systemd unit so it starts on boot; stop script when idle overnight

Don't put AWS keys anywhere but the instance role. IMDSv2 only.
Full commands TBD when we're allowed to touch AWS (not this phase).
