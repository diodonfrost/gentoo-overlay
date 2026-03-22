# Copyright 2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit go-module

DESCRIPTION="GitLab CLI brings GitLab to your terminal"
HOMEPAGE="https://gitlab.com/gitlab-org/cli"
SRC_URI="https://gitlab.com/gitlab-org/cli/-/archive/v${PV}/cli-v${PV}.tar.gz -> ${P}.tar.gz"

S="${WORKDIR}/cli-v${PV}"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

BDEPEND=">=dev-lang/go-1.25.8"

# Network access needed for Go module dependencies
RESTRICT="network-sandbox"

src_unpack() {
	default
}

src_compile() {
	ego build \
		-ldflags "-s -w -X 'main.version=${PV}'" \
		-o glab \
		./cmd/glab
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
}
