#!/bin/bash
# ---DOC-START---
# summary: Install the Xorg window system and X11 utilities.
# description: |
#   Installs `xorg`, `xinit`, `x11-xserver-utils`.
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

echo "==> Installing Xorg window system"

echo "Updating package lists..."
apt update -q

echo "Installing Xorg window system..."
apt install -y \
    xorg \
    xinit \
    x11-xserver-utils

echo ""
echo "Xorg window system installed successfully."
