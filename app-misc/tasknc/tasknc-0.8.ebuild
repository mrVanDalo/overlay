# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit autotools

DESCRIPTION="tasknc is a ncurses wrapper for task warrior written in C"
HOMEPAGE="https://github.com/lharding/tasknc"
SRC_URI="https://github.com/lharding/${PN}/archive/v${PV}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND="
dev-lang/perl
"
RDEPEND="${DEPEND}
sys-libs/ncurses
"

PATCHES=(
	"${FILESDIR}/version.patch"
	"${FILESDIR}/no-doc.patch"
)
