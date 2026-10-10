# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="Incredibly fast JavaScript runtime, bundler, test runner, and package manager"
HOMEPAGE="https://bun.sh/ https://github.com/oven-sh/bun"
SRC_URI="
	amd64? ( https://github.com/oven-sh/bun/releases/download/bun-v${PV}/bun-linux-x64.zip )
	arm64? ( https://github.com/oven-sh/bun/releases/download/bun-v${PV}/bun-linux-aarch64.zip )
"
S="${WORKDIR}"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm64"
RESTRICT="mirror strip"

RDEPEND="sys-libs/glibc"
BDEPEND="app-arch/unzip"

QA_PREBUILT="usr/bin/bun"

src_install() {
	local arch
	case ${ARCH} in
		amd64) arch="x64" ;;
		arm64) arch="aarch64" ;;
		*) die "Unsupported architecture: ${ARCH}" ;;
	esac

	newbin "bun-linux-${arch}/bun" bun
}
