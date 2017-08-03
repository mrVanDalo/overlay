#!/bin/bash

cat >/etc/portage/package.use/supercollider <<EOF
media-sound/supercollider jack -portaudio
EOF

cat >/etc/portage/package.keywords <<EOF
# required by =media-sound/supercollider-3.8.0 (argument)
=media-sound/supercollider-3.8.0 ~amd64
EOF
