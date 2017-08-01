# My Gentoo overlay

[![Test Status](https://travis-ci.org/mrVanDalo/overlay.svg?branch=master)](https://travis-ci.org/mrVanDalo/overlay)

To add just put the following file into 
`/etc/portage/repos.conf/my-overlay`

    [mrVanDalo]
    location = /home/overlays/my-overlay
    masters = gentoo
    auto-sync = no

and clone this project into `/home/overlays/my-overlay`

## Tests

To run the tests locally you need docker and understand what you are doing

> ./travis/repoman.sh
