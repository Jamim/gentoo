# Copyright 1999-2018 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=6

PYTHON_COMPAT=( python{2_7,3_{4,5,6,7}} )
ECM_KDEINSTALLDIRS="false"
KDE_AUTODEPS="false"
KDE_DEBUG="false"
KDE_QTHELP="false"
KDE_TEST="false"
inherit kde5 python-any-r1

DESCRIPTION="Extra modules and scripts for CMake"
HOMEPAGE="https://cgit.kde.org/extra-cmake-modules.git"

LICENSE="BSD"
KEYWORDS="~amd64 ~arm ~arm64 ~hppa ~ppc ~ppc64 ~x86 ~amd64-fbsd"
IUSE="doc test"

DEPEND="
	doc? (
		${PYTHON_DEPS}
		$(python_gen_any_dep 'dev-python/sphinx[${PYTHON_USEDEP}]')
	)
	test? (
		$(add_qt_dep qtcore)
		$(add_qt_dep linguist-tools)
	)
"
RDEPEND="
	app-arch/libarchive[bzip2]
"

PATCHES=(
	"${FILESDIR}/${PN}-5.49.0-no-fatal-warnings.patch"
	"${FILESDIR}/${P}-fix-FindQHelpGenerator.patch"
)

python_check_deps() {
	has_version "dev-python/sphinx[${PYTHON_USEDEP}]"
}

pkg_setup() {
	use doc && python-any-r1_pkg_setup
}

src_configure() {
	local mycmakeargs=(
		-DBUILD_QTHELP_DOCS=$(usex doc)
		-DBUILD_HTML_DOCS=$(usex doc)
		-DBUILD_MAN_DOCS=$(usex doc)
		-DDOC_INSTALL_DIR=/usr/share/doc/"${PF}"
	)
	use test && mycmakeargs+=( -DCMAKE_DISABLE_FIND_PACKAGE_PythonModuleGeneration=ON )

	kde5_src_configure
}

src_test() {
	# ECMToolchainAndroidTest passes but then breaks src_install
	# ECMPoQmToolsTest is broken, bug #627806
	local myctestargs=(
		-E "(ECMToolchainAndroidTest|ECMPoQmToolsTest)"
	)

	kde5_src_test
}
