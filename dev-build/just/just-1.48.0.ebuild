# Copyright 2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cargo

DESCRIPTION="Just a command runner"
HOMEPAGE="https://just.systems"
SRC_URI="https://github.com/casey/${PN}/archive/${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="CC0-1.0"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

BDEPEND=">=virtual/rust-1.85.0"

# Network access needed for cargo dependencies
RESTRICT="network-sandbox"

src_unpack() {
	default
}

src_compile() {
	cargo build --release || die "cargo build failed"
}

src_install() {
	dobin target/release/just
}
