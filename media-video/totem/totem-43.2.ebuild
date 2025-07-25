# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8
PYTHON_COMPAT=( python3_{11..14} )
PYTHON_REQ_USE="threads(+)"

inherit gnome.org gnome2-utils meson virtualx xdg python-single-r1

DESCRIPTION="Media player for GNOME"
HOMEPAGE="https://apps.gnome.org/Totem/ https://gitlab.gnome.org/GNOME/totem/"

LICENSE="GPL-2+ LGPL-2+"
SLOT="0"
KEYWORDS="~amd64 ~arm ~arm64 ~loong ~ppc ~ppc64 ~riscv ~x86"
IUSE="gtk-doc +python test"
# see bug #359379
REQUIRED_USE="
	python? ( ${PYTHON_REQUIRED_USE} )
"
RESTRICT="!test? ( test )"

COMMON_DEPEND="
	>=dev-libs/glib-2.72.0:2
	>=x11-libs/gtk+-3.22.0:3[introspection]
	>=gui-libs/libhandy-1.5.0:1
	>=media-libs/gstreamer-1.21.1:1.0
	>=media-libs/gst-plugins-base-1.21.1:1.0[pango]
	>=media-libs/gst-plugins-good-1.21.1:1.0
	>=media-libs/grilo-0.3.0:0.3[playlist]
	>=dev-libs/libpeas-1.1.0:0[gtk]
	>=dev-libs/totem-pl-parser-3.26.5:0=[introspection]
	gnome-base/gnome-desktop:3=
	gnome-base/gsettings-desktop-schemas
	media-libs/libepoxy
	>=x11-libs/cairo-1.14
	x11-libs/gdk-pixbuf:2
	>=dev-libs/gobject-introspection-1.54:=

	python? (
		${PYTHON_DEPS}
		$(python_gen_cond_dep '
			>=dev-python/pygobject-2.90.3:3[${PYTHON_USEDEP}]
		')
	)
"
RDEPEND="${COMMON_DEPEND}
	media-plugins/grilo-plugins:0.3
	>=media-plugins/gst-plugins-gtk-1.21.1:1.0[opengl]
	>=media-plugins/gst-plugins-meta-1.21.1:1.0
	>=media-plugins/gst-plugins-taglib-1.21.1:1.0
	x11-themes/adwaita-icon-theme
	>=dev-libs/libportal-0.7:0=[gtk]
	python? (
		x11-libs/pango[introspection]
		>=dev-libs/libpeas-1.1.0:0[python,${PYTHON_SINGLE_USEDEP}]
		$(python_gen_cond_dep '
			dev-python/dbus-python[${PYTHON_USEDEP}]
		')
	)
"
DEPEND="${COMMON_DEPEND}
	x11-base/xorg-proto
"
# perl for pod2man
# Prevent dev-python/pylint dep, bug #482538
BDEPEND="
	dev-lang/perl
	gtk-doc? ( >=dev-util/gtk-doc-1.14
		app-text/docbook-xml-dtd:4.5 )
	dev-util/glib-utils
	dev-util/itstool
	>=sys-devel/gettext-0.19.8
	virtual/pkgconfig
"

PATCHES=(
	"${FILESDIR}"/gst-inspect-sandbox.patch # Allow disabling calls to gst-inspect (sandbox issue)
)

pkg_setup() {
	use python && python-single-r1_pkg_setup
}

src_prepare() {
	default
	xdg_environment_reset

	# Drop pointless samplepython plugin from build
	sed -e '/samplepython/d' -i src/plugins/meson.build || die
}

src_configure() {
	local native_file="${T}"/meson.ini.local
	# We don't want to run pylint tests. They're only for style.
	cat >> ${native_file} <<-EOF || die
	[binaries]
	pylint='pylint-falseified'
	EOF

	local emesonargs=(
		-Dhelp=true
		-Denable-easy-codec-installation=yes
		-Denable-python=$(usex python yes no)
		-Dlibportal=enabled
		-Dwith-plugins=all
		$(meson_use gtk-doc enable-gtk-doc)
		-Dprofile=default
		-Dinspector-page=false
		-Dgst-inspect=false
		--native-file "${native_file}"
	)
	meson_src_configure
}

src_test() {
	virtx meson_src_test
}

src_install() {
	local -x GST_PLUGIN_SYSTEM_PATH_1_0= # bug 812170
	meson_src_install
	if use python ; then
		python_optimize "${ED}"/usr/$(get_libdir)/totem/plugins/
	fi
}

pkg_postinst() {
	xdg_pkg_postinst
	gnome2_schemas_update
}

pkg_postrm() {
	xdg_pkg_postrm
	gnome2_schemas_update
}
