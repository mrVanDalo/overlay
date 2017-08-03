#!/bin/bash

set -ex

# choose where to take difference from
CURRENT_BRANCH="${TRAVIS_BRANCH:master}"
if [[ ${CURRENT_BRANCH} == "master" ]]
then
    exit 0 # don't build for master
    DIFF_TEST_AGAINST="HEAD^"
else
    DIFF_TEST_AGAINST="origin/master"
    # fix missing master branch : pull stuff
    git remote set-branches origin master
    git fetch origin master
fi

function emerge_config(){
    PACKAGE=$1
    CONFIG_PATCH=$2

    docker run \
           --rm=true \
           --tty=true \
           --interactive=true \
           --volume="${HOME}/.portage:/usr/portage" \
           --volume="${PWD}:/ebuilds" \
           palo/gentoo-test:latest \
           /ebuilds/travis/emerge/emerge.sh "${PACKAGE}" "${CONFIG_PATCH}"
}

function test_package(){
    EBUILD=$1

    PKG_NAME=$( basename "${EBUILD}" ".ebuild" )
    PKG_CATEGORY="${EBUILD%%/*}"

    # TODO : this part is still a bit fragile => make it more robust
    PKG_CONFIG_FOLDER="./travis/config/${PKG_CATEGORY}/${PKG_NAME}"
    if [[ -d "${PKG_CONFIG_FOLDER}" ]] && [[ $(ls -A "${PKG_CONFIG_FOLDER}") ]]
    then
        PKG_CONFIG_FILES=($(ls ${PKG_CONFIG_FOLDER} | grep '\.sh$' ))
        cat <<EOF
------------------------------------

  Found Configuration Files : ${#PKG_CONFIG_FILES[@]}
    -> ${PKG_CONFIG_FILES[@]}

------------------------------------
EOF

        for CONFIG_PATCH in "${PKG_CONFIG_FILES[@]}"
        do
            emerge_config "=${PKG_CATEGORY}/${PKG_NAME}" "${PKG_CONFIG_FOLDER}/${CONFIG_PATCH}"
        done
    else
        emerge_config "=${PKG_CATEGORY}/${PKG_NAME}"
    fi


}


# Get list of new or changed ebuilds
EBUILDS=($(git diff --name-only --diff-filter=d ${DIFF_TEST_AGAINST} | grep '\.ebuild$')) || true

# Emerge the ebuilds
for EBUILD in "${EBUILDS[@]}"
do
    test_package ${EBUILD}
done
