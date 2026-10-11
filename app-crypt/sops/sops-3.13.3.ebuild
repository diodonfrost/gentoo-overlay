# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit go-module

DESCRIPTION="Simple and flexible tool for managing secrets"
HOMEPAGE="https://getsops.io/ https://github.com/getsops/sops"
SRC_URI="https://github.com/getsops/sops/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="MPL-2.0"
# Dependent module licenses
LICENSE+=" Apache-2.0 BSD BSD-2 ISC MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm64"
RESTRICT="network-sandbox test"

BDEPEND=">=dev-lang/go-1.24"

src_compile() {
	ego build \
		-ldflags "-X 'github.com/getsops/sops/v3/version.Version=${PV}'" \
		-o sops \
		./cmd/sops
}

src_install() {
	dobin sops
}
