# Copyright 2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="Incredibly fast JavaScript runtime, bundler, test runner, and package manager"
HOMEPAGE="https://bun.sh"
SRC_URI="
	amd64? ( https://github.com/oven-sh/bun/releases/download/bun-v${PV}/bun-linux-x64.zip )
	arm64? ( https://github.com/oven-sh/bun/releases/download/bun-v${PV}/bun-linux-aarch64.zip )
"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

RESTRICT="bindist mirror strip"

BDEPEND="app-arch/unzip"

QA_PREBUILT="usr/bin/bun"

S="${WORKDIR}"

src_install() {
	local arch
	case ${ARCH} in
		amd64) arch="x64" ;;
		arm64) arch="aarch64" ;;
	esac

	newbin "bun-linux-${arch}/bun" bun
}
