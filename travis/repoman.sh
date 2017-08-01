#!/bin/bash
#
# run repoman unit test

set -xe

if [ "${TRAVIS_EVENT_TYPE}" != "cron" ]
then
    docker run \
           --rm=true \
           --tty=true \
           --interactive=true \
           --volume="${HOME}/.portage:/usr/portage" \
           --volume="${PWD}:/ebuilds" \
           palo/gentoo-test:latest \
           /ebuilds/travis/repoman/repoman-unit-test.sh
fi
