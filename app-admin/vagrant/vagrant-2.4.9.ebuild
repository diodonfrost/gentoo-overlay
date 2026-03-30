# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="Tool for building and distributing development environments"
HOMEPAGE="https://developer.hashicorp.com/vagrant https://github.com/hashicorp/vagrant"
SRC_URI="https://github.com/hashicorp/vagrant/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="BUSL-1.1"
SLOT="0"
KEYWORDS="~amd64 ~arm64"
RESTRICT="network-sandbox test"

RDEPEND="
	dev-lang/ruby:*
	dev-libs/openssl:=
"
DEPEND="${RDEPEND}"
BDEPEND="
	dev-lang/ruby
	dev-ruby/rubygems
"

src_compile() {
	gem build vagrant.gemspec || die "gem build failed"
}

src_install() {
	local dest="/opt/${PN}"

	gem install --no-document \
		--install-dir "${ED}${dest}" \
		--bindir "${ED}${dest}/bin" \
		"${PN}-${PV}.gem" || die "gem install failed"

	# Wrapper script with isolated GEM_HOME
	dodir /usr/bin
	cat > "${ED}/usr/bin/${PN}" <<-EOF
	#!/bin/sh
	export GEM_HOME="${dest}"
	export GEM_PATH="${dest}"
	exec "${dest}/bin/${PN}" "\$@"
	EOF
	fperms 0755 "/usr/bin/${PN}"
}
