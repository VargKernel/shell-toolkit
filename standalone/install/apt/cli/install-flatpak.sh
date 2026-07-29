#!/bin/bash

# ---DOC-START---
# summary: Install flatpak, add the Flathub remote, optionally enable KDE Discover integration.
# description: |
#   Installs `flatpak`, adds the [Flathub](https://flathub.org) remote, optionally enables KDE Discover integration.
# sudo: true
# interactive: false
# idempotent: true
# dependencies: none
# ---DOC-END---

set -euo pipefail

export DEBIAN_FRONTEND=noninteractive

echo "==> Installing Flatpak"

echo "Installing Flatpak..."
sudo apt update
sudo apt install -y flatpak

echo "Adding Flathub repository..."
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

echo "KDE Discover Flatpak backend..."
if dpkg -s plasma-discover >/dev/null 2>&1; then
    sudo apt install -y plasma-discover-backend-flatpak
    echo "Discover Flatpak support enabled"
else
    echo "KDE Discover not installed, skipping integration"
fi

echo ""
echo "Flatpak setup complete"
