# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cargo desktop xdg

DESCRIPTION="Open source extensible speech-to-text application working offline"
HOMEPAGE="https://handy.computer/ https://github.com/cjpais/Handy"
SRC_URI="https://github.com/cjpais/Handy/archive/v${PV}.tar.gz -> ${P}.tar.gz"
S="${WORKDIR}/Handy-${PV}"

LICENSE="MIT"
# Dependent crate/npm licenses
LICENSE+=" Apache-2.0 BSD-2 ISC MPL-2.0 Unicode-3.0"
SLOT="0"
KEYWORDS="~amd64"
RESTRICT="network-sandbox test"

BDEPEND="
	>=dev-lang/rust-1.85.0
	dev-build/cmake
	dev-util/vulkan-headers
	media-libs/shaderc
	net-libs/nodejs[npm]
	virtual/pkgconfig
"

RDEPEND="
	dev-libs/glib:2
	gui-libs/gtk-layer-shell
	media-libs/alsa-lib
	media-libs/vulkan-loader
	x11-libs/gtk+:3
	net-libs/webkit-gtk:4.1
"

DEPEND="${RDEPEND}"

QA_FLAGS_IGNORED="usr/bin/handy"

# Override cargo eclass src_unpack to bypass vendor directory setup
# since this overlay fetches crate dependencies at build time
src_unpack() {
	default
}

src_prepare() {
	default
	# Replace bun with npm and disable updater signing for build
	sed -i \
		-e 's|"beforeBuildCommand": "bun run build"|"beforeBuildCommand": "npm run build"|' \
		-e '/"createUpdaterArtifacts"/s|true|false|' \
		src-tauri/tauri.conf.json || die
}

src_compile() {
	# Remove cargo eclass config that redirects crates-io to a
	# non-existent vendor directory — tauri needs network access
	rm -f "${ECARGO_HOME}/config.toml" || die

	# Build frontend assets
	npm install --ignore-scripts || die "npm install failed"
	npm run build || die "frontend build failed"

	# Build the Rust binary directly instead of using tauri CLI bundler
	# (tauri build -b deb is an anti-pattern in Gentoo ebuilds)
	export PKG_CONFIG_PATH="/usr/lib64/pkgconfig:/usr/share/pkgconfig"
	cd src-tauri || die
	cargo build --release || die "cargo build failed"
}

src_install() {
	dobin src-tauri/target/release/handy

	insinto /usr/share/${PN}/resources
	doins -r src-tauri/resources/*

	newicon -s 32 src-tauri/icons/32x32.png handy.png
	newicon -s 64 src-tauri/icons/64x64.png handy.png
	newicon -s 128 src-tauri/icons/128x128.png handy.png
	newicon -s 256 src-tauri/icons/128x128@2x.png handy.png

	make_desktop_entry handy "Handy" handy "Audio;Accessibility;Utility;"
}
