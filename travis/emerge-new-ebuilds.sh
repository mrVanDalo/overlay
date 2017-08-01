#!/bin/bash

set -ex

# choose where to take difference from
CURRENT_BRANCH="${TRAVIS_BRANCH:master}"
if [[ ${CURRENT_BRANCH} == "master" ]]
then
    DIFF_TEST_AGAINST="HEAD^^"
else
    DIFF_TEST_AGAINST="origin/master"
    # fix missing master branch : pull stuff
    git remote set-branches origin master
    git fetch origin master
fi



# Get list of new or changed ebuilds
EBUILDS=($(git diff --name-only --diff-filter=d ${DIFF_TEST_AGAINST} | grep '\.ebuild$')) || true

# Emerge the ebuilds
for EBUILD in "${EBUILDS[@]}"
do
    docker run \
           --rm=true \
           --tty=true \
           --interactive=true \
           --volume="${HOME}/.portage:/usr/portage" \
           --volume="${PWD}:/ebuilds" \
           palo/gentoo-test:latest \
           /ebuilds/travis/emerge/emerge.sh "${EBUILD}"
done
