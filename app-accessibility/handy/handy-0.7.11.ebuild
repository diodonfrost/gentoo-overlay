# Copyright 2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cargo desktop xdg

DESCRIPTION="Free, open source, and extensible speech-to-text application that works completely offline"
HOMEPAGE="https://handy.computer"
SRC_URI="https://github.com/cjpais/Handy/archive/v${PV}.tar.gz -> ${P}.tar.gz"
S="${WORKDIR}/Handy-${PV}"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"

BDEPEND="
	>=dev-lang/rust-1.85.0
	net-libs/nodejs[npm]
"

RDEPEND="
	dev-libs/glib:2
	gui-libs/gtk-layer-shell
	x11-libs/gtk+:3
	net-libs/webkit-gtk:4.1
"
DEPEND="${RDEPEND}"

# Network access needed for cargo and npm/bun dependencies
RESTRICT="network-sandbox"

src_unpack() {
	default
}

src_compile() {
	cd "${S}" || die
	npm install --ignore-scripts || die "npm install failed"
	npm run build || die "npm build failed"
	cd "${S}/src-tauri" || die
	cargo build --release || die "cargo build failed"
}

src_install() {
	insinto /opt/handy
	doins -r src-tauri/resources
	exeinto /opt/handy
	doexe src-tauri/target/release/handy
	dosym ../../opt/handy/handy /usr/bin/handy

	newicon -s 32 src-tauri/icons/32x32.png handy.png
	newicon -s 64 src-tauri/icons/64x64.png handy.png
	newicon -s 128 src-tauri/icons/128x128.png handy.png
	newicon -s 256 src-tauri/icons/128x128@2x.png handy.png

	make_desktop_entry handy "Handy" handy "Audio;Accessibility;Utility;"
}
