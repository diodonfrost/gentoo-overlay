# Copyright 2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit go-module

DESCRIPTION="Flexible orchestration tool that allows Infrastructure as Code to scale"
HOMEPAGE="https://terragrunt.com"
SRC_URI="https://github.com/gruntwork-io/${PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

BDEPEND=">=dev-lang/go-1.25"

# Network access needed for Go module dependencies
RESTRICT="network-sandbox"

src_unpack() {
	default
}

src_compile() {
	ego build \
		-ldflags "-s -w -X 'github.com/gruntwork-io/go-commons/version.Version=v${PV}'" \
		-o terragrunt \
		.
}

src_install() {
	dobin terragrunt
}
