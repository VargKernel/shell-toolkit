#!/bin/bash

# ---DOC-START---
# summary: Install Steam from Flathub.
# description: |
#   Installs [Steam](https://store.steampowered.com) from Flathub.
# sudo: false
# interactive: false
# idempotent: true
# ---DOC-END---

set -euo pipefail

export DEBIAN_FRONTEND=noninteractive

echo "[*] Installing Steam via Flatpak..."

flatpak install -y flathub com.valvesoftware.Steam

echo "[*] Steam installed"

echo "[INFO] Launch command:"
echo "flatpak run com.valvesoftware.Steam"

echo "[INFO] Installed apps:"
flatpak list | grep steam || true
