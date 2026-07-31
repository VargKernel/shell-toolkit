#!/bin/bash
# ---DOC-START---
# summary: Install the core shell environment and base userland utilities.
# description: |
#   Installs `sudo`, `bash`, `bash-completion`, `coreutils`, `findutils`, `grep`, `gawk`, `sed`,
#   `diffutils`, `patch`, `procps`, `psmisc`, `util-linux`, `file`, `which`.
# sudo: true
# interactive: false
# idempotent: true
# dependencies: none
# ---DOC-END---
set -euo pipefail
export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
export DEBIAN_FRONTEND=noninteractive

if [[ $EUID -ne 0 ]]; then
    echo "Please log in as root and run this script."
    exit 1
fi
echo "==> Installing core shell environment"

echo "Updating package lists..."
apt update -q

echo "Installing core shell environment..."
apt install -y \
    sudo \
    bash \
    bash-completion \
    coreutils \
    findutils \
    grep \
    gawk \
    sed \
    diffutils \
    patch \
    procps \
    psmisc \
    util-linux \
    file \
    which

echo ""
echo "Core shell environment installed successfully."
