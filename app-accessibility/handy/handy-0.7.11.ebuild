# Copyright 2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cargo

DESCRIPTION="Free, open source, and extensible speech-to-text application that works completely offline"
HOMEPAGE="https://handy.computer"
SRC_URI="https://github.com/cjpais/${PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"

BDEPEND="
	>=virtual/rust-1.85.0
	net-libs/nodejs[npm]
"

RDEPEND="
	dev-libs/glib:2
	x11-libs/gtk+:3
	net-libs/webkit-gtk:4.1
"
DEPEND="${RDEPEND}"

# Network access needed for cargo and npm/bun dependencies
RESTRICT="network-sandbox"

src_compile() {
	cd "${S}" || die
	npm install || die "npm install failed"
	npm run build || die "npm build failed"
	cd "${S}/src-tauri" || die
	cargo build --release || die "cargo build failed"
}

src_install() {
	dobin src-tauri/target/release/handy
}
