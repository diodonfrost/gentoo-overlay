# Copyright 2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit go-module

DESCRIPTION="GitHub CLI brings GitHub to your terminal"
HOMEPAGE="https://cli.github.com"
SRC_URI="https://github.com/cli/cli/archive/v${PV}.tar.gz -> ${P}.tar.gz"

S="${WORKDIR}/cli-${PV}"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

BDEPEND=">=dev-lang/go-1.26.1"

# Network access needed for Go module dependencies
RESTRICT="network-sandbox"

src_unpack() {
	default
}

src_compile() {
	ego build \
		-ldflags "-s -w -X 'github.com/cli/cli/v2/internal/build.Version=${PV}'" \
		-o gh \
		./cmd/gh
}

src_install() {
	dobin gh
}
