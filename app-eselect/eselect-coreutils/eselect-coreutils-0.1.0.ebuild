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
	elog "Choose a provider with:"
	elog "    eselect coreutils set <gnu|uutils>"
	elog ""
	elog "Then prepend the dispatch directory to PATH so the choice"
	elog "takes precedence over /usr/bin, e.g. in your shell rc:"
	elog "    export PATH=\"/usr/local/lib/eselect-coreutils/bin:\${PATH}\""
}
