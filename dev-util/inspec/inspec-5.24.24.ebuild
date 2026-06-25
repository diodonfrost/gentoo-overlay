# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="Infrastructure testing framework with a human-readable language"
HOMEPAGE="https://docs.chef.io/inspec/ https://github.com/inspec/inspec"
SRC_URI="https://github.com/inspec/inspec/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64 ~arm64"
RESTRICT="network-sandbox test"

RDEPEND="dev-lang/ruby:*"
BDEPEND="
	dev-lang/ruby
	dev-ruby/rubygems
"

src_compile() {
	gem build inspec-core.gemspec || die "gem build inspec-core failed"
	gem build inspec.gemspec || die "gem build inspec failed"
	cd "${S}/inspec-bin" || die
	gem build inspec-bin.gemspec || die "gem build inspec-bin failed"
}

src_install() {
	local dest="/opt/${PN}"

	gem install --no-document \
		--install-dir "${ED}${dest}" \
		--bindir "${ED}${dest}/bin" \
		"inspec-core-${PV}.gem" || die "gem install inspec-core failed"

	gem install --no-document \
		--install-dir "${ED}${dest}" \
		--bindir "${ED}${dest}/bin" \
		"inspec-${PV}.gem" || die "gem install inspec failed"

	cd "${S}/inspec-bin" || die
	gem install --no-document \
		--install-dir "${ED}${dest}" \
		--bindir "${ED}${dest}/bin" \
		"inspec-bin-${PV}.gem" || die "gem install inspec-bin failed"

	# Wrapper script with isolated GEM_HOME
	dodir /usr/bin
	cat > "${ED}/usr/bin/inspec" <<-EOF
	#!/bin/sh
	export GEM_HOME="${dest}"
	export GEM_PATH="${dest}"
	exec "${dest}/bin/inspec" "\$@"
	EOF
	fperms 0755 /usr/bin/inspec
}
