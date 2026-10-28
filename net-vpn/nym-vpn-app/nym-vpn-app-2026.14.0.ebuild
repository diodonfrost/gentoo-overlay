# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

RUST_MIN_VER="1.97.1"

inherit cargo desktop xdg

DESCRIPTION="NymVPN desktop client (GUI frontend for nym-vpnd)"
HOMEPAGE="https://nym.com/ https://github.com/nymtech/nym-vpn-client"
# The nym-vpn-client monorepo is released as a single nym-vpn-v* tag that
# covers both the core and the desktop app; both ebuilds share the tarball.
SRC_URI="https://github.com/nymtech/nym-vpn-client/archive/refs/tags/nym-vpn-v${PV}.tar.gz -> nym-vpn-client-${PV}.tar.gz"
S="${WORKDIR}/nym-vpn-client-nym-vpn-v${PV}"

LICENSE="GPL-3"
# Dependent crate/npm licenses
LICENSE+=" Apache-2.0 BSD BSD-2 ISC MIT MPL-2.0 Unicode-3.0 ZLIB"
SLOT="0"
KEYWORDS="~amd64 ~arm64"
IUSE="appindicator"
RESTRICT="network-sandbox test"

BDEPEND="
	dev-build/cmake
	dev-libs/protobuf
	net-libs/nodejs[npm]
	virtual/pkgconfig
"

# vpnd_compat.toml pins the daemon version range the app accepts.
# The tray uses ksni (StatusNotifierItem over D-Bus); libappindicator is only
# dlopen'ed as a fallback when no StatusNotifierWatcher is running.
RDEPEND="
	>=net-vpn/nym-vpn-core-${PV}
	dev-libs/glib:2
	dev-libs/openssl
	dev-libs/wayland
	net-libs/libsoup:3.0
	net-libs/webkit-gtk:4.1
	sys-apps/dbus
	x11-libs/cairo
	x11-libs/gdk-pixbuf:2
	x11-libs/gtk+:3
	x11-libs/pango
	appindicator? ( dev-libs/libayatana-appindicator )
"

DEPEND="${RDEPEND}"

QA_FLAGS_IGNORED="usr/bin/nym-vpn-app"

# Override cargo eclass src_unpack to bypass vendor directory setup
# since this overlay fetches crate dependencies at build time
src_unpack() {
	default
}

src_compile() {
	# Remove cargo eclass config that redirects crates-io to a
	# non-existent vendor directory — crates are fetched at build time
	rm -f "${ECARGO_HOME}/config.toml" || die

	cd nym-vpn-app || die

	# Build frontend assets (tsc && vite build -> ../dist)
	npm ci --ignore-scripts || die "npm ci failed"
	npm run build || die "frontend build failed"

	# build-info-build's build script globs **/*.rs below src-tauri and
	# panics when a transient file under target/ vanishes mid-walk while
	# other crates compile in parallel; keep the target dir out of the tree
	export CARGO_TARGET_DIR="${WORKDIR}/target"
	# Upstream release profile strips the binary itself; let Portage do it
	export CARGO_PROFILE_RELEASE_STRIP=false

	# Build the Rust binary directly instead of using the tauri CLI bundler.
	# tauri/custom-protocol is what `tauri build` adds automatically; without
	# it the release binary still points at the dev server (devUrl).
	cd src-tauri || die
	cargo build --release --locked --features tauri/custom-protocol \
		|| die "cargo build failed"
}

src_install() {
	dobin "${WORKDIR}"/target/release/nym-vpn-app

	local icons=nym-vpn-app/src-tauri/icons
	newicon -s 32 "${icons}"/32x32.png nym-vpn-app.png
	newicon -s 64 "${icons}"/64x64.png nym-vpn-app.png
	newicon -s 128 "${icons}"/128x128.png nym-vpn-app.png
	newicon -s 256 "${icons}"/128x128@2x.png nym-vpn-app.png

	domenu "${FILESDIR}"/nym-vpn-app.desktop
}

pkg_postinst() {
	xdg_pkg_postinst

	elog "nym-vpn-app needs the nym-vpnd daemon from net-vpn/nym-vpn-core"
	elog "to be running. See its post-install message for how to enable it."
}
