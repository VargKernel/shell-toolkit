#!/bin/bash

# ---DOC-START---
# summary: Install Telegram Desktop from Flathub.
# description: |
#   Installs [Telegram Desktop](https://desktop.telegram.org) from Flathub.
# sudo: false
# interactive: false
# idempotent: true
# dependencies: none
# ---DOC-END---

set -euo pipefail

export DEBIAN_FRONTEND=noninteractive

echo "==> Installing Telegram via Flatpak"

echo "[*] Installing Telegram via Flatpak..."

flatpak install -y flathub org.telegram.desktop

echo "[*] Telegram installed"

echo "[INFO] Launch command:"
echo "flatpak run org.telegram.desktop"

echo "[INFO] Installed apps:"
flatpak list | grep telegram || true
