#!/bin/bash
#
# run repoman-unit tests

set -ex

# Disable news messages from portage and disable rsync's output
export FEATURES="-news" \
       PORTAGE_RSYNC_EXTRA_OPTS="-q"

emerge --sync

# Run the tests
repoman full \
        --include-dev
