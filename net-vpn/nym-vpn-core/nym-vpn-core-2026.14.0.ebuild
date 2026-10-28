# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

RUST_MIN_VER="1.97.1"

inherit cargo shell-completion systemd toolchain-funcs

DESCRIPTION="NymVPN daemon (nym-vpnd) and command-line client (nym-vpnc)"
HOMEPAGE="https://nym.com/ https://github.com/nymtech/nym-vpn-client"
# The nym-vpn-client monorepo is released as a single nym-vpn-v* tag that
# covers both the core and the desktop app; both ebuilds share the tarball.
SRC_URI="https://github.com/nymtech/nym-vpn-client/archive/refs/tags/nym-vpn-v${PV}.tar.gz -> nym-vpn-client-${PV}.tar.gz"
S="${WORKDIR}/nym-vpn-client-nym-vpn-v${PV}"

LICENSE="GPL-3"
# Dependent crate/module licenses
LICENSE+=" Apache-2.0 BSD BSD-2 ISC MIT MPL-2.0 Unicode-3.0 ZLIB"
SLOT="0"
KEYWORDS="~amd64 ~arm64"
RESTRICT="network-sandbox test"

BDEPEND="
	>=dev-lang/go-1.27
	dev-build/cmake
	dev-libs/protobuf
	virtual/pkgconfig
"

RDEPEND="
	acct-group/nym-vpn
	dev-libs/openssl
	net-libs/libmnl
	net-libs/libnftnl
	sys-apps/dbus
	sys-auth/polkit
"

DEPEND="${RDEPEND}"

QA_FLAGS_IGNORED="
	usr/bin/nym-diagnostic
	usr/bin/nym-exclude
	usr/bin/nym-socks5-proxy
	usr/bin/nym-vpnc
	usr/bin/nym-vpnd
"

# Override cargo eclass src_unpack to bypass vendor directory setup
# since this overlay fetches crate dependencies at build time
src_unpack() {
	default
}

src_compile() {
	# Remove cargo eclass config that redirects crates-io to a
	# non-existent vendor directory — crates are fetched at build time
	rm -f "${ECARGO_HOME}/config.toml" || die

	# libwg.a: wireguard-go built as a Go c-archive, statically linked
	# into nym-vpnd by the nym-wg-go crate (expects build/lib/<triple>/)
	export GOFLAGS="-mod=mod" GOTOOLCHAIN=local CGO_ENABLED=1
	export GOPATH="${WORKDIR}/go" GOMODCACHE="${WORKDIR}/go-mod"
	export GOCACHE="${T}/go-cache"
	./wireguard/build-wireguard-go.sh || die "wireguard-go build failed"

	# nym-bin-common's bin_info macros read VERGEN_GIT_* at compile time;
	# the tarball has no git metadata, so let vergen emit placeholders
	export VERGEN_DEFAULT_ON_ERROR=1

	# Only the binaries shipped in upstream's linux release tarball
	cd nym-vpn-core || die
	cargo build --release --locked \
		-p nym-vpnd -p nym-vpnc -p nym-exclude -p nym-socks5-proxy \
		-p nym-diagnostic \
		|| die "cargo build failed"

	if ! tc-is-cross-compiler; then
		einfo "Generating shell completion files"
		local vpnc=target/release/nym-vpnc
		${vpnc} completions bash > nym-vpnc.bash || die
		${vpnc} completions zsh > nym-vpnc.zsh || die
		${vpnc} completions fish > nym-vpnc.fish || die
	fi
}

src_install() {
	cd nym-vpn-core || die

	dobin target/release/{nym-vpnd,nym-vpnc,nym-diagnostic,nym-socks5-proxy}

	# Split-tunnel helper: upstream deb/AUR packages install it setuid root
	# so that unprivileged users can launch excluded applications
	dobin target/release/nym-exclude
	fperms 4755 /usr/bin/nym-exclude

	if ! tc-is-cross-compiler; then
		newbashcomp nym-vpnc.bash nym-vpnc
		newzshcomp nym-vpnc.zsh _nym-vpnc
		dofishcomp nym-vpnc.fish
	fi

	# Daemon writes this policy itself on first start; ship it so polkit
	# knows the action before nym-vpnd has ever run
	insinto /usr/share/polkit-1/actions
	doins crates/nym-ipc/.pkg/com.nymvpn.vpnd.unix-access.policy

	systemd_dounit crates/nym-vpnd/.pkg/aur/nym-vpnd.service
	newinitd "${FILESDIR}"/nym-vpnd.initd nym-vpnd
}

pkg_postinst() {
	elog "Enable and start the daemon:"
	elog "  systemd: systemctl enable --now nym-vpnd"
	elog "  OpenRC:  rc-update add nym-vpnd default && rc-service nym-vpnd start"
	elog
	elog "Users in the 'nym-vpn' group can control the daemon without a"
	elog "polkit authentication prompt:"
	elog "  usermod -aG nym-vpn <user>"
	elog
	elog "The graphical client is available as net-vpn/nym-vpn-app."
}
