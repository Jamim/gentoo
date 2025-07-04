# Copyright 2022-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8
inherit cmake dot-a

CommitId=d6860c477c99f1fce9e28eb206891af3c0e1a1d7

DESCRIPTION="C-style (a-la printf) logging library"
HOMEPAGE="https://github.com/pytorch/cpuinfo/"
SRC_URI="https://github.com/pytorch/cpuinfo/archive/${CommitId}.tar.gz
	-> cpuinfo-${PV}.tar.gz"

S="${WORKDIR}"/clog

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm64 ~x86"
IUSE="test"

RDEPEND="!<dev-libs/cpuinfo-${PV}"
BDEPEND="test? ( dev-cpp/gtest )"
RESTRICT="!test? ( test )"

PATCHES=( "${FILESDIR}"/${P}-test.patch )

src_unpack() {
	unpack "${A}"
	mv cpuinfo-${CommitId}/deps/clog clog || die
	rm -r cpuinfo-${CommitId} || die
}

src_prepare() {
	sed -i \
		-e "/CMAKE_MINIMUM_REQUIRED/s:3.1:3.10:" \
		CMakeLists.txt \
		|| die
	cmake_src_prepare
}

src_configure() {
	lto-guarantee-fat
	local mycmakeargs=(
		-DUSE_SYSTEM_LIBS=ON
		-DUSE_SYSTEM_GOOGLETEST=ON
		-DCLOG_BUILD_TESTS=$(usex test ON OFF)
	)
	cmake_src_configure
}

src_install() {
	cmake_src_install
	strip-lto-bytecode
}
