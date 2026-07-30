# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit go-module

DESCRIPTION="Command line interface for the Scaleway cloud platform"
HOMEPAGE="https://www.scaleway.com/en/ https://github.com/scaleway/scaleway-cli"
SRC_URI="https://github.com/scaleway/scaleway-cli/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="Apache-2.0"
# Dependent module licenses
LICENSE+=" BSD BSD-2 ISC MIT MPL-2.0"
SLOT="0"
KEYWORDS="~amd64 ~arm64"
RESTRICT="network-sandbox test"

BDEPEND=">=dev-lang/go-1.26"

src_compile() {
	ego build \
		-ldflags "-X 'main.Version=v${PV}'" \
		-o scw \
		./cmd/scw
}

src_install() {
	dobin scw
}
