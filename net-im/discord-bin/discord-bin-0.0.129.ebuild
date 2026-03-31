# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit desktop xdg

DESCRIPTION="All-in-one voice and text chat for gamers"
HOMEPAGE="https://discord.com/"
SRC_URI="https://dl.discordapp.net/apps/linux/${PV}/discord-${PV}.tar.gz"

LICENSE="all-rights-reserved"
SLOT="0"
KEYWORDS="~amd64"
RESTRICT="bindist mirror strip test"

RDEPEND="
	app-accessibility/at-spi2-core:2
	dev-libs/expat
	dev-libs/glib:2
	dev-libs/nspr
	dev-libs/nss
	media-libs/alsa-lib
	media-libs/fontconfig
	media-libs/mesa[gbm(+)]
	net-print/cups
	sys-apps/dbus
	sys-apps/util-linux
	sys-libs/glibc
	x11-libs/cairo
	x11-libs/gdk-pixbuf:2
	x11-libs/gtk+:3
	x11-libs/libdrm
	x11-libs/libX11
	x11-libs/libXcomposite
	x11-libs/libXdamage
	x11-libs/libXext
	x11-libs/libXfixes
	x11-libs/libXrandr
	x11-libs/libXScrnSaver
	x11-libs/libxcb
	x11-libs/libxkbcommon
	x11-libs/libxshmfence
	x11-libs/pango
"

QA_PREBUILT="opt/discord/*"

S="${WORKDIR}/Discord"

src_prepare() {
	default
	sed -i \
		-e "s|/usr/share/discord/Discord|/opt/discord/Discord|" \
		discord.desktop || die
}

src_install() {
	insinto /opt/discord
	doins -r .
	fperms +x /opt/discord/Discord
	fperms +x /opt/discord/chrome_crashpad_handler

	# chrome-sandbox requires setuid for Chromium sandbox to function
	fowners root /opt/discord/chrome-sandbox
	fperms 4711 /opt/discord/chrome-sandbox

	dosym -r /opt/discord/Discord /usr/bin/discord

	domenu discord.desktop

	newicon -s 256 discord.png discord.png
}
