# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit go-module shell-completion toolchain-funcs

DESCRIPTION="Command-line tool for communicating with a Kubernetes cluster"
HOMEPAGE="https://kubernetes.io/ https://github.com/kubernetes/kubernetes"
SRC_URI="https://github.com/kubernetes/kubernetes/archive/v${PV}.tar.gz -> ${P}.tar.gz"

S="${WORKDIR}/kubernetes-${PV}"

LICENSE="Apache-2.0"
# Dependent module licenses
LICENSE+=" BSD BSD-2 ISC MIT MPL-2.0"
SLOT="0"
KEYWORDS="~amd64 ~arm64"
RESTRICT="network-sandbox test"

BDEPEND=">=dev-lang/go-1.25"

src_compile() {
	ego build \
		-ldflags "-X 'k8s.io/client-go/pkg/version.gitVersion=v${PV}'" \
		-o kubectl \
		./cmd/kubectl

	if ! tc-is-cross-compiler; then
		einfo "Generating shell completion files"
		./kubectl completion bash > kubectl.bash || die
		./kubectl completion zsh > kubectl.zsh || die
		./kubectl completion fish > kubectl.fish || die
	fi
}

src_install() {
	dobin kubectl

	if ! tc-is-cross-compiler; then
		newbashcomp kubectl.bash kubectl
		newzshcomp kubectl.zsh _kubectl
		dofishcomp kubectl.fish
	fi
}
