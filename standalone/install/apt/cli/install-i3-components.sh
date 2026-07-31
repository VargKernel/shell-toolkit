#!/bin/bash
# ---DOC-START---
# summary: Install i3 companion components.
# description: |
#   Installs `polybar`, `dunst`, `rofi`.
# sudo: true
# interactive: false
# idempotent: true
# dependencies: 02-install-i3-wm.sh
# ---DOC-END---
set -euo pipefail
export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
export DEBIAN_FRONTEND=noninteractive

if [[ $EUID -ne 0 ]]; then
    echo "Please log in as root and run this script."
    exit 1
fi

echo "==> Installing i3 companion components"

echo "Updating package lists..."
apt update -q

echo "Installing i3 companion components..."
apt install -y \
    polybar \
    dunst \
    rofi

echo ""
echo "i3 companion components installed successfully."
