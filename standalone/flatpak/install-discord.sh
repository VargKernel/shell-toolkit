#!/bin/bash

# ---DOC-START---
# summary: Install Discord from Flathub.
# description: |
#   Installs [Discord](https://discord.com) from Flathub.
# sudo: false
# interactive: false
# idempotent: true
# dependencies: none
# ---DOC-END---

set -euo pipefail

export DEBIAN_FRONTEND=noninteractive

echo "==> Installing Discord via Flatpak"

echo "[*] Installing Discord via Flatpak..."

flatpak install -y flathub com.discordapp.Discord

echo "[*] Discord installed"

echo "[INFO] Launch command:"
echo "flatpak run com.discordapp.Discord"

echo "[INFO] Installed apps:"
flatpak list | grep discord || true
