# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit bash-completion-r1

DESCRIPTION="A simple tool written in bash to memorize stuff."
HOMEPAGE="http://palovandalo.com/memo/"
SRC_URI="https://github.com/mrVanDalo/${PN}/archive/${PV}.tar.gz"

SLOT="0"
LICENSE="GPL-2"
KEYWORDS="~amd64 ~x86"
IUSE=""

RDEPEND="
	app-text/tree
	sys-apps/ack
"

# prevent to install README.md
DOCS=( LICENSE )

src_install(){
	default

	doman doc/${PN}.1

	newbashcomp completion/${PN}.bash ${PN}
	dobin ${PN}
}
