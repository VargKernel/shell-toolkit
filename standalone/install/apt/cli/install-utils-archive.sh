#!/bin/bash
# ---DOC-START---
# summary: Install archive and compression utilities.
# description: |
#   Installs `tar`, `gzip`, `bzip2`, `xz-utils`, `zstd`, `zip`, `unzip`, `p7zip-full`.
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

echo "==> Installing archive and compression utilities"

echo "Updating package lists..."
apt update -q

echo "Installing archive and compression utilities..."
apt install -y \
    tar \
    gzip \
    bzip2 \
    xz-utils \
    zstd \
    zip \
    unzip \
    p7zip-full

echo ""
echo "Archive and compression utilities installed successfully."
