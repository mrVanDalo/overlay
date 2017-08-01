#!/bin/bash
#
# emerge a package

set -xe

if [[ "$#" -le 0 ]] || [[ "$#" -gt 2 ]]
then
  echo "Usage: $0 =<ebuild category>/<ebuild name>-<version>" >&2
  echo "Usage: $0 <ebuild category>/<ebuild name>" >&2
  exit 1
fi

PACKAGE=$1
CONFIG=$2
cat <<EOF
-----------------------------------------------

     Emerging ${PACKAGE}
              ${CONFIG}

-----------------------------------------------
EOF



# Disable news messages from portage and disable rsync's output
export FEATURES="-news" \
       PORTAGE_RSYNC_EXTRA_OPTS="-q"


# Fix repository name
cat >/etc/portage/repos.conf/localOverlay <<EOF
[mrVanDalo]
location = /ebuilds
masters = gentoo
auto-sync = no
EOF

# Update the portage tree
emerge --sync

# Set portage's distdir to /tmp/distfiles
# This is a workaround for a bug in portage/git-r3 where git-r3 can't
# create the distfiles/git-r3 directory when no other distfiles have been
# downloaded by portage first, which happens when using binary packages
# https://bugs.gentoo.org/481434
export DISTDIR="/tmp/distfiles"

# Source ebuild specific env vars
unset ACCEPT_KEYWORDS
unset USE

if [[ -z ${CONFIG} ]]
then
    echo "no config-file set emerge as default"
else
    echo "run config-file ${CONFIG}"
    bash ${CONFIG}
fi

# Emerge dependencies first
emerge \
    --quiet-build \
    --buildpkg \
    --usepkg \
    --onlydeps \
    --autounmask=y \
    --autounmask-continue=y \
    "${PACKAGE}"

# Emerge the ebuild itself
emerge \
    --verbose \
    "${PACKAGE}"
