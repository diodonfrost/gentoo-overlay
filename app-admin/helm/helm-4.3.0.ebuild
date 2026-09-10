# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit go-module shell-completion toolchain-funcs

DESCRIPTION="The Kubernetes Package Manager"
HOMEPAGE="https://helm.sh/ https://github.com/helm/helm"
SRC_URI="https://github.com/helm/helm/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="Apache-2.0"
# Dependent module licenses
LICENSE+=" BSD BSD-2 ISC MIT MPL-2.0 ZLIB"
SLOT="0"
KEYWORDS="~amd64 ~arm64"
RESTRICT="network-sandbox test"

BDEPEND=">=dev-lang/go-1.25"

src_compile() {
	ego build \
		-ldflags "-X 'helm.sh/helm/v4/internal/version.version=v${PV}'" \
		-o helm \
		./cmd/helm

	if ! tc-is-cross-compiler; then
		einfo "Generating shell completion files"
		./helm completion bash > helm.bash || die
		./helm completion zsh > helm.zsh || die
		./helm completion fish > helm.fish || die
	fi
}

src_install() {
	dobin helm

	if ! tc-is-cross-compiler; then
		newbashcomp helm.bash helm
		newzshcomp helm.zsh _helm
		dofishcomp helm.fish
	fi
}
