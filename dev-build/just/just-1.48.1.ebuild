# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cargo shell-completion toolchain-funcs

DESCRIPTION="Just a command runner (with syntax inspired by 'make')"
HOMEPAGE="
	https://just.systems/
	https://crates.io/crates/just
	https://github.com/casey/just
"
SRC_URI="https://github.com/casey/just/archive/${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="CC0-1.0"
# Dependent crate licenses
LICENSE+=" Apache-2.0 BSD-2 MIT MPL-2.0 Unicode-3.0 ZLIB"
SLOT="0"
KEYWORDS="~amd64 ~arm64"
RESTRICT="network-sandbox test"

BDEPEND=">=dev-lang/rust-1.85.0"

QA_FLAGS_IGNORED="usr/bin/just"

# Override cargo eclass src_unpack to bypass vendor directory setup
# since this overlay fetches crate dependencies at build time
src_unpack() {
	default
}

src_compile() {
	cargo build --release || die

	if ! tc-is-cross-compiler; then
		einfo "Generating shell completion files"
		target/release/just --completions bash > just.bash || die
		target/release/just --completions zsh > just.zsh || die
		target/release/just --completions fish > just.fish || die
	fi
}

src_install() {
	dobin target/release/just

	if ! tc-is-cross-compiler; then
		newbashcomp just.bash just
		newzshcomp just.zsh _just
		dofishcomp just.fish
	fi
}
