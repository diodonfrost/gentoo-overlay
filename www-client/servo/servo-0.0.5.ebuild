# Copyright 2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cargo desktop xdg

DESCRIPTION="Lightweight, high-performance web browser engine written in Rust"
HOMEPAGE="https://servo.org"
SRC_URI="https://github.com/${PN}/${PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="MPL-2.0"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

BDEPEND="
	dev-lang/rust
	dev-build/cmake
	dev-util/gperf
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
	# Remove cargo eclass config that replaces crates-io with a local directory,
	# servo needs to fetch crates and git deps at build time
	rm -f "${ECARGO_HOME}/config.toml" || die
	CARGO_TARGET_DIR=target cargo build --release -p servoshell || die "cargo build failed"
}

src_install() {
	# Install binary and resources to /opt/servo so servo can find
	# its resources/ directory relative to the executable
	exeinto /opt/servo
	doexe target/release/servo

	insinto /opt/servo/resources
	doins resources/*

	dosym ../../opt/servo/servo /usr/bin/servo

	newicon resources/servo.svg servo.svg
	newicon -s 64 resources/servo_64.png servo.png
	newicon -s 1024 resources/servo_1024.png servo.png

	make_desktop_entry servo "Servo" servo "Network;WebBrowser;" \
		"MimeType=text/html;text/xml;application/xhtml+xml;x-scheme-handler/http;x-scheme-handler/https;"
}
