# Copyright 2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit go-module

DESCRIPTION="Command-line tool for communicating with a Kubernetes cluster"
HOMEPAGE="https://kubernetes.io"
SRC_URI="https://github.com/kubernetes/kubernetes/archive/v${PV}.tar.gz -> ${P}.tar.gz"

S="${WORKDIR}/kubernetes-${PV}"

LICENSE="Apache-2.0"
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
		-ldflags "-s -w" \
		-o kubectl \
		./cmd/kubectl
}

src_install() {
	dobin kubectl
}
