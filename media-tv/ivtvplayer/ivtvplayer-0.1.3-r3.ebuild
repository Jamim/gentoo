# Copyright 1999-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

DESCRIPTION="Simple IVTV command line TV and radio player with support of LIRC"
HOMEPAGE="https://sourceforge.net/projects/ivtvplayer/"
SRC_URI="https://downloads.sourceforge.net/${PN}/${P}.tar.gz"

SLOT="0"
LICENSE="GPL-2"
KEYWORDS="~amd64 ~x86"
IUSE="gtk"

RDEPEND="media-libs/libv4l[utils(-)]
	 || ( media-video/mplayer[v4l]
		media-video/mplayer[dvb] )
	 media-sound/alsa-utils
	 dev-perl/XML-Simple
	 gtk? ( dev-perl/Gtk2 )
	 dev-perl/X-Osd
	 >=dev-perl/Lirc-Client-1.50"
DEPEND="${RDEPEND}"

src_install() {
	dobin bin/itv
	dobin bin/iradio
	use gtk && dobin bin/ictl
	dodoc doc/README doc/CHANGES
	dodoc -r conf
}

pkg_postinst() {
	einfo ""
	einfo "Example of itv, iradio and its LIRC configuration file is located in"
	einfo "directory /usr/share/doc/${PF}/."
	einfo ""
}
