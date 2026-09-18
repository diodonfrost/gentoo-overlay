# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit go-module

DESCRIPTION="Tool for creating machine images for multiple platforms"
HOMEPAGE="https://developer.hashicorp.com/packer https://github.com/hashicorp/packer"
SRC_URI="https://github.com/hashicorp/packer/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="BUSL-1.1"
# Dependent module licenses
LICENSE+=" Apache-2.0 BSD BSD-2 ISC MIT MPL-2.0"
SLOT="0"
KEYWORDS="~amd64 ~arm64"
RESTRICT="network-sandbox test"

BDEPEND=">=dev-lang/go-1.24"

src_compile() {
	ego build \
		-ldflags "-X 'github.com/hashicorp/packer/version.Version=${PV}'" \
		-o "${T}"/packer \
		.
}

src_install() {
	dobin "${T}"/packer
}
