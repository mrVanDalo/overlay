#!/bin/bash

cat >>/etc/portage/make.conf<<EOF

CPU_FLAGS_X86="sse mmxext mmx"
EOF

