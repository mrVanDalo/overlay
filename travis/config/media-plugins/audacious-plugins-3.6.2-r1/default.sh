#!/bin/bash

cat >>/etc/portage/package.use/audacious<<EOF
media-plugins/audacious-plugins alsa
EOF
