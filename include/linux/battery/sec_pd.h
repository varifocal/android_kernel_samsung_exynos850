/* SPDX-License-Identifier: GPL-2.0 */
/*
 * sec_pd.h - minimal reconstruction for the SM-A127F (a12s) bring-up.
 *
 * Why this file exists:
 *   drivers/usb/typec/sm/sm5714/{sm5714_pd,sm5714_policy,sm5714_typec}.c and
 *   drivers/muic/sm/sm5714/sm5714-muic-pdic.c include <linux/battery/sec_pd.h>
 *   unconditionally, but that header is shipped in neither the SM-A127F
 *   open-source release nor the Lineage tree (only battery_notifier.h is).
 *   See ~/rom/logs/missing_headers.md for the full investigation.
 *
 * Why this is NOT a verbatim copy of the gta4xls header:
 *   In this 4.19 tree generation `struct pdic_notifier_struct` (and the
 *   PDIC_SINK_STATUS sink_status member it carries) lives in
 *   <linux/battery/battery_notifier.h> (lines 143-147), which these .c files
 *   include anyway. The LineageOS gta4xls kernel is a *later* generation in
 *   which that struct was moved into sec_pd.h, so copying it verbatim would
 *   redefine the struct and fail to compile.
 *
 * What the a12s code actually needs from this header:
 *   An exhaustive grep of the four consumers shows only 7 references, ALL of
 *   them in the #else branch of CONFIG_BATTERY_NOTIFIER or
 *   IS_ENABLED(CONFIG_BATTERY_NOTIFIER):
 *     - SEC_PD_SINK_STATUS  (sm5714_pd.c:1613, 1 occurrence)
 *     - fp_sec_pd_select_pdo / _select_pps / _vpdo_auth /
 *       _manual_ccopen_req / _get_apdo_max_power (sm5714_pd.c:2344-2351)
 *   This board sets CONFIG_BATTERY_NOTIFIER=y (defconfig:681, stock:5279), so
 *   every one of those references is preprocessed out and the code uses the
 *   globals declared in sm5714_pd.h:988-991 instead - a header we already
 *   have. The three other .c files reference nothing from sec_pd.h at all;
 *   for them the include is vestigial.
 *
 * So the only thing required is a declaration for the type name, and it must
 * alias the struct this tree already defines: in the non-BATTERY_NOTIFIER
 * path `SEC_PD_SINK_STATUS *` is assigned `&...pd_noti.sink_status`, whose
 * type is exactly PDIC_SINK_STATUS. Aliasing keeps that path type-correct
 * should CONFIG_BATTERY_NOTIFIER ever be turned off, without redefining
 * anything.
 *
 * If a fuller SM-A127F source drop becomes available, replace this file with
 * the byte-exact original and re-check the two struct generations.
 */

#ifndef __SEC_PD_H__
#define __SEC_PD_H__

#include <linux/battery/battery_notifier.h>

/*
 * SEC_PD_SINK_STATUS is the sink-status block of a PD notification. This tree
 * carries the equivalent definition as PDIC_SINK_STATUS inside
 * battery_notifier.h (see header comment), so alias it rather than
 * redefining a struct that is already visible here.
 */
typedef PDIC_SINK_STATUS SEC_PD_SINK_STATUS;

#endif /* __SEC_PD_H__ */