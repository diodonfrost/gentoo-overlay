# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit go-module

DESCRIPTION="Infrastructure as Code SDK for building and deploying cloud infrastructure"
HOMEPAGE="https://www.pulumi.com/ https://github.com/pulumi/pulumi"
SRC_URI="https://github.com/pulumi/pulumi/archive/v${PV}.tar.gz -> ${P}.tar.gz"

S="${WORKDIR}/${P}/pkg"

LICENSE="Apache-2.0"
# Dependent module licenses
LICENSE+=" BSD BSD-2 ISC MIT MPL-2.0"
SLOT="0"
KEYWORDS="~amd64 ~arm64"
RESTRICT="network-sandbox test"

BDEPEND=">=dev-lang/go-1.25"

src_compile() {
	ego build \
		-ldflags "-X 'github.com/pulumi/pulumi/sdk/v3/go/common/version.Version=v${PV}'" \
		-o pulumi \
		./cmd/pulumi
}

src_install() {
	dobin pulumi
}
