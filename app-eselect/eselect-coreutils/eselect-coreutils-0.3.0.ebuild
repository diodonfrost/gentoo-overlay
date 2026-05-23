# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="Eselect module to switch the system coreutils provider (GNU/uutils)"
HOMEPAGE="https://github.com/diodonfrost/gentoo-overlay"
S="${WORKDIR}"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

RDEPEND="app-admin/eselect"

src_install() {
	insinto /usr/share/eselect/modules
	doins "${FILESDIR}/coreutils.eselect"
}

pkg_postinst() {
	local prev_state="${EROOT}/var/lib/eselect-coreutils/active"
	local old_dispatch="${EROOT}/usr/local/lib/eselect-coreutils"

	# Migration from <=0.2.0: the dispatch-dir + /etc/profile.d mechanism
	# is replaced by direct /usr/local/bin overrides. The profile.d file
	# is Portage-tracked and removed by the prior version's unmerge; the
	# dispatch dir was runtime-created and needs a manual sweep.
	if [[ -d ${old_dispatch} ]]; then
		rm -rf "${old_dispatch}"
		elog "Removed obsolete dispatch directory ${old_dispatch#${EROOT}}."
	fi

	# Carry forward the previously active provider under the new
	# mechanism so admins who were on uutils stay on uutils.
	if [[ -e ${prev_state} ]]; then
		local prev
		prev=$(< "${prev_state}")
		prev=${prev//[[:space:]]/}
		if [[ ${prev} == uutils ]]; then
			eselect coreutils set uutils
			elog ""
			elog "Re-applied 'uutils' as active provider via the new mechanism."
		fi
	fi

	elog ""
	elog "Switch the active coreutils provider with:"
	elog "    eselect coreutils set uutils   # uutils takes over (needs sys-apps/uutils-coreutils)"
	elog "    eselect coreutils set gnu      # removes overrides; /usr/bin (GNU) wins"
	elog ""
	elog "Activation creates /usr/local/bin/<util> -> /usr/bin/uu-<util>"
	elog "symlinks which shadow /usr/bin/<util> via the standard PATH."
	elog "No relogin needed. Effect is global: shells, sudo, cron, services."
	elog "Scripts calling /usr/bin/<util> by absolute path are unaffected."
}

pkg_prerm() {
	# Clean up overrides and state on real removal, not upgrades.
	if [[ -z ${REPLACED_BY_VERSION} ]]; then
		eselect coreutils unset 2>/dev/null
	fi
}
