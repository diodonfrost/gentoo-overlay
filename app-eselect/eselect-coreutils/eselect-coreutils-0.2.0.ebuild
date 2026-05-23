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

	# Prepend the dispatch dir to PATH for login shells. /etc/env.d/
	# would only append, leaving /usr/bin ahead — defeating the point.
	insinto /etc/profile.d
	doins "${FILESDIR}/eselect-coreutils.sh"
}

pkg_postinst() {
	# Populate the dispatch directory on first install so the system
	# keeps a working ls/cat/... before the admin picks a provider.
	if [[ -z ${REPLACING_VERSIONS} && ! -e ${EROOT}/var/lib/eselect-coreutils/active ]]; then
		eselect coreutils set gnu
	fi

	elog ""
	elog "Switch the active coreutils provider with:"
	elog "    eselect coreutils set uutils   # Rust uutils-coreutils"
	elog "    eselect coreutils set gnu      # GNU coreutils (default)"
	elog ""
	elog "Open a new login shell (or run 'source /etc/profile') once"
	elog "so the /etc/profile.d/eselect-coreutils.sh PATH entry takes effect."
}

pkg_prerm() {
	# Clean up dispatch symlinks and state on real removal, not upgrades.
	if [[ -z ${REPLACED_BY_VERSION} ]]; then
		eselect coreutils unset 2>/dev/null
	fi
}
