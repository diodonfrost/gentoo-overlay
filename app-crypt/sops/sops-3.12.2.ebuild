# Copyright 2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit go-module

DESCRIPTION="Simple and flexible tool for managing secrets"
HOMEPAGE="https://getsops.io"
SRC_URI="https://github.com/getsops/${PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="MPL-2.0"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

BDEPEND=">=dev-lang/go-1.24"

# Network access needed for Go module dependencies
RESTRICT="network-sandbox"

src_unpack() {
	default
}

src_compile() {
	ego build \
		-ldflags "-s -w -X 'github.com/getsops/sops/v3/version.Version=${PV}'" \
		-o sops \
		./cmd/sops
}

src_install() {
	dobin sops
}
