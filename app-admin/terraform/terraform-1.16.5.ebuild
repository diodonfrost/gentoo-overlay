# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit bash-completion-r1 go-module

DESCRIPTION="Tool for building, changing, and versioning infrastructure safely"
HOMEPAGE="https://developer.hashicorp.com/terraform https://github.com/hashicorp/terraform"
SRC_URI="https://github.com/hashicorp/terraform/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="BUSL-1.1"
# Dependent module licenses
LICENSE+=" Apache-2.0 BSD BSD-2 ISC MIT MPL-2.0"
SLOT="0"
KEYWORDS="~amd64 ~arm64"
RESTRICT="network-sandbox test"

BDEPEND=">=dev-lang/go-1.25"

src_compile() {
	CGO_ENABLED=0 ego build \
		-ldflags "-X 'github.com/hashicorp/terraform/version.dev=no'" \
		-o terraform \
		.
}

src_install() {
	dobin terraform

	newbashcomp - terraform <<< 'complete -C /usr/bin/terraform terraform'
}
