#!/bin/bash
# ---DOC-START---
# summary: Install the Xorg window system, X11 utilities, and terminal emulator.
# description: |
#   Installs `xorg`, `xinit`, `x11-xserver-utils`, `kitty`.
#
#   `kitty` is installed in the same transaction as `xorg` because the `xorg`
#   metapackage depends on `<x-terminal-emulator>`, an alternative dependency
#   that apt resolves to `gnome-terminal` by default (pulling in gvfs,
#   nautilus-extension-gnome-terminal, and other GNOME components) when no
#   higher-priority terminal is present in the same apt transaction.
#   Installing `kitty` alongside `xorg` makes apt resolve the alternative to
#   `kitty` instead, avoiding the GNOME dependency chain entirely.
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
# kitty must be installed in the same apt transaction as xorg. The xorg
# metapackage depends on <x-terminal-emulator> (an alternative dependency),
# which apt resolves to gnome-terminal by default, pulling in gvfs and other
# GNOME components. Including kitty here makes apt satisfy the alternative
# with kitty instead, so gnome-terminal is never installed.
apt install -y \
    kitty \
    xorg \
    xinit \
    x11-xserver-utils

echo ""
echo "Xorg window system installed successfully."
