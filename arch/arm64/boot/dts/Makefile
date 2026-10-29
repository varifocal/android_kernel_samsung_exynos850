# SPDX-License-Identifier: GPL-2.0

# Exynos 3830
dtbo-y += exynos/exynos3830-universal3830_r15.dtbo
dtbo-y += exynos/exynos3830-universal3830_r01.dtbo
dtb-y  += exynos/exynos7-espresso.dtb
dtbo-y += exynos/exynos3830-universal3830_r04.dtbo
dtbo-y += exynos/exynos3830-universal3830_r00.dtbo
dtbo-y += exynos/exynos3830-universal3830_r02.dtbo
dtb-y  += exynos/exynos5433-tm2.dtb
dtb-y  += exynos/exynos5433-tm2e.dtb
dtbo-y += exynos/exynos3830-universal3830_r03.dtbo
dtb-y  += exynos/exynos3830.dtb
# Galaxy A12 (a12s): stock base DTB, exact copy of Samsung's
# arch/arm64/boot/dts/exynos/exynos3830.dts from the SM-A127F opensource
# release. Kept alongside the Lineage exynos3830.dtb so both can be
# boot-tested (device/samsung/a12s configs/kernel/exynos850.cfg selects
# which one lands in boot.img).
dtb-y  += exynos/exynos3830-a12s.dtb

# Galaxy A21s
dtbo-y += samsung/a21s/a21s_eur_open_w00_r00.dtbo
dtbo-y += samsung/a21s/a21s_eur_open_w00_r03.dtbo
dtbo-y += samsung/a21s/a21s_eur_open_w00_r01.dtbo
dtbo-y += samsung/a21s/a21s_eur_open_w00_r06.dtbo
dtbo-y += samsung/a21s/a21s_eur_open_w00_r02.dtbo

targets += dtbs
DTB_LIST  := $(dtb-y) $(dtbo-y)
always    := $(DTB_LIST)

dtbs: $(addprefix $(obj)/, $(DTB_LIST))

clean-files := *.dtb*
