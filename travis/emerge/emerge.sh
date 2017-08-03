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

function die(){
    cat <<EOF
!---------------------------------------------!

 Failed Build : ${PACKAGE}
                ${CONFIG}

!---------------------------------------------!
EOF
    exit 1
}


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

TRAVIS_EBUILD_HELP_PACKAGES=()
if [[ -z ${CONFIG} ]]
then
    echo "no config-file set emerge as default"
else
    echo "run config-file ${CONFIG}"
    . ${CONFIG}
fi

function help_package_emerge_and_exit(){
    help_pkg=$1
    cat <<EOF
------------------------------------------------------------------------------------

  install help package : ${help_pkg}

------------------------------------------------------------------------------------
EOF

    emerge \
        --quiet-build \
        --buildpkg \
        --usepkg \
        --getbinpkg \
        --autounmask=y \
        --autounmask-continue=y \
        "${help_pkg}" || die

    cat <<EOF




------------------------------------------------------------------------------------

 This is just a build that is depended to be in the cache
 otherwise the real build will not proceed in time.



  >>>>>   HIT THE REBUILD BUTTON !!! <<<<<<<



------------------------------------------------------------------------------------


EOF

    # yes it should exit with success
    # otherwise the cache will not be stored by travis
    exit 1
}

# help travis to fill cache without running in timeouts
for help_pkg in "${TRAVIS_EBUILD_HELP_PACKAGES[@]}"
do
    emerge -p --usepkgonly ${help_pkg} || help_package_emerge_and_exit ${help_pkg}
done


# Emerge dependencies first
emerge \
    --quiet-build \
    --buildpkg \
    --usepkg \
    --getbinpkg \
    --onlydeps \
    --autounmask=y \
    --autounmask-continue=y \
    "${PACKAGE}" || die

# Emerge the ebuild itself
emerge \
    --verbose \
    --usepkg=n \
    --getbinpkg=n \
    --buildpkg \
    "${PACKAGE}" || die




# Print out some information about dependencies at the end
cat <<EOF
----------------------------------------------------------

  RDEPEND information :

----------------------------------------------------------
EOF
cat <<EOF

linked packages :

EOF
qlist -e ${PACKAGE} \
    | grep -ve "'" \
    | xargs scanelf -L -n -q -F "%n #F" \
    | tr , ' ' \
    | xargs qfile -Cv \
    | sort -u \
    | awk '{print $1}' \
    | uniq \
    | xargs qatom --format  "%{CATEGORY}/%{PN}" || exit 0

cat <<EOF

linked virtual packages :

EOF
qlist -e ${PACKAGE} \
    | grep -ve "'" \
    | xargs scanelf -L -n -q -F "%n #F" \
    | tr , ' ' \
    | xargs qfile -Cv \
    | sort -u \
    | awk '{print $1}' \
    | uniq \
    | xargs qatom --format  "%{CATEGORY}/%{PN}" \
    | xargs -L1 qdepends --nocolor --name-only --rdepend --query \
    | grep ^virtual  \
    | uniq || exit 0

