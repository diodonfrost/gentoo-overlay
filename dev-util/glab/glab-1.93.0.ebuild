# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit go-module shell-completion toolchain-funcs

DESCRIPTION="GitLab CLI brings GitLab to your terminal"
HOMEPAGE="https://gitlab.com/gitlab-org/cli"
SRC_URI="https://gitlab.com/gitlab-org/cli/-/archive/v${PV}/cli-v${PV}.tar.bz2 -> ${P}.tar.bz2"

S="${WORKDIR}/cli-v${PV}"

LICENSE="MIT"
# Dependent module licenses
LICENSE+=" Apache-2.0 BSD BSD-2 ISC MPL-2.0"
SLOT="0"
KEYWORDS="~amd64 ~arm64"
RESTRICT="network-sandbox test"

BDEPEND="
	>=dev-lang/go-1.25
	dev-vcs/git
"

src_compile() {
	ego build \
		-ldflags "-X 'main.version=${PV}'" \
		-o glab \
		./cmd/glab

	if ! tc-is-cross-compiler; then
		einfo "Generating shell completion files"
		./glab completion -s bash > glab.bash || die
		./glab completion -s zsh > glab.zsh || die
		./glab completion -s fish > glab.fish || die
	fi
}

src_test() {
	local tmpdir="${T}/glab-test-git"
	mkdir -p "${tmpdir}" || die
	cd "${tmpdir}" || die
	git init || die
	git config user.email "test@test.com" || die
	git config user.name "Test" || die
	touch testfile || die
	git add testfile || die
	git commit -m "initial" || die
	cd "${S}" || die
	ego test ./...
}

src_install() {
	dobin glab

	if ! tc-is-cross-compiler; then
		newbashcomp glab.bash glab
		newzshcomp glab.zsh _glab
		dofishcomp glab.fish
	fi
}
