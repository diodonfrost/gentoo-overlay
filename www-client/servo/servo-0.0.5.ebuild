# Copyright 2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cargo desktop

DESCRIPTION="Lightweight, high-performance web browser engine written in Rust"
HOMEPAGE="https://servo.org"
SRC_URI="https://github.com/${PN}/${PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="MPL-2.0"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

BDEPEND="
	>=virtual/rust-1.86
	dev-build/cmake
	dev-build/gperf
	llvm-core/clang
	virtual/pkgconfig
"

RDEPEND="
	dev-libs/glib:2
	dev-libs/openssl
	media-libs/fontconfig
	media-libs/freetype:2
	media-libs/gstreamer:1.0
	media-libs/gst-plugins-base:1.0
	media-libs/gst-plugins-good:1.0
	media-libs/gst-plugins-bad:1.0
	media-libs/harfbuzz
	media-libs/mesa
	media-libs/vulkan-loader
	sys-apps/dbus
	sys-libs/libunwind
	virtual/libudev
	x11-libs/libX11
	x11-libs/libXcursor
	x11-libs/libXi
	x11-libs/libXrandr
	x11-libs/libxcb
	x11-libs/libxkbcommon
"

DEPEND="${RDEPEND}"

# Network access needed for Rust crate dependencies
RESTRICT="network-sandbox"

src_compile() {
	cargo build --release -p servoshell || die "cargo build failed"
}

src_install() {
	dobin target/release/servoshell
	dosym servoshell /usr/bin/servo
}
