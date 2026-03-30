# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit go-module

DESCRIPTION="Flexible orchestration tool that allows Infrastructure as Code to scale"
HOMEPAGE="https://terragrunt.gruntwork.io/ https://github.com/gruntwork-io/terragrunt"
SRC_URI="https://github.com/gruntwork-io/terragrunt/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="MIT"
# Dependent module licenses
LICENSE+=" Apache-2.0 BSD BSD-2 ISC MPL-2.0"
SLOT="0"
KEYWORDS="~amd64 ~arm64"
RESTRICT="network-sandbox test"

BDEPEND=">=dev-lang/go-1.25"

src_compile() {
	ego build \
		-ldflags "-X 'github.com/gruntwork-io/go-commons/version.Version=v${PV}'" \
		-o terragrunt \
		.
}

src_install() {
	dobin terragrunt
}
