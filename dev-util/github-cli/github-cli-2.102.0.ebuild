# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit go-module shell-completion toolchain-funcs

DESCRIPTION="GitHub CLI brings GitHub to your terminal"
HOMEPAGE="https://cli.github.com/ https://github.com/cli/cli"
SRC_URI="https://github.com/cli/cli/archive/v${PV}.tar.gz -> ${P}.tar.gz"

S="${WORKDIR}/cli-${PV}"

LICENSE="MIT"
# Dependent module licenses
LICENSE+=" Apache-2.0 BSD BSD-2 ISC MPL-2.0"
SLOT="0"
KEYWORDS="~amd64 ~arm64"
RESTRICT="network-sandbox test"

RDEPEND=">=dev-vcs/git-1.7.3"

BDEPEND=">=dev-lang/go-1.26"

src_compile() {
	ego build \
		-ldflags "-X 'github.com/cli/cli/v2/internal/build.Version=${PV}'" \
		-o gh \
		./cmd/gh

	if ! tc-is-cross-compiler; then
		einfo "Generating shell completion files"
		./gh completion -s bash > gh.bash || die
		./gh completion -s zsh > gh.zsh || die
		./gh completion -s fish > gh.fish || die
	fi
}

src_install() {
	dobin gh

	if ! tc-is-cross-compiler; then
		newbashcomp gh.bash gh
		newzshcomp gh.zsh _gh
		dofishcomp gh.fish
	fi
}
