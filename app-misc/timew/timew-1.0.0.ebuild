# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit cmake-utils

DESCRIPTION="Timewarrior is a companion to Taskwarrior"
HOMEPAGE="http://taskwarrior.org/docs/timewarrior/"
SRC_URI="https://taskwarrior.org/download/${P}.tar.gz"

#S=${WORKDIR}/timew-1.0.0

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND=""
RDEPEND="${DEPEND}"
