# Copyright 2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit go-module

DESCRIPTION="Infrastructure as Code SDK for building and deploying cloud infrastructure"
HOMEPAGE="https://www.pulumi.com"
SRC_URI="https://github.com/${PN}/${PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"

S="${WORKDIR}/${P}/pkg"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

BDEPEND=">=dev-lang/go-1.25.6"

# Network access needed for Go module dependencies
RESTRICT="network-sandbox"

src_unpack() {
	default
}

src_compile() {
	ego build \
		-ldflags "-s -w -X 'github.com/pulumi/pulumi/sdk/v3/go/common/version.Version=v${PV}'" \
		-o pulumi \
		./cmd/pulumi
}

src_test_prepare() {
	"${S}/pulumi" version || die "pulumi version check failed"
}

src_install() {
	dobin pulumi
}
