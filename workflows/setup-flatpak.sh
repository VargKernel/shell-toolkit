#!/bin/bash

# ---DOC-START---
# summary: Install Flatpak + Flathub + Discord, Steam, Telegram in one step.
# description: |
#   Installs [Flatpak](https://flatpak.org) and a standard set of GUI applications in one step.
#
#   - Runs in order: `install-flatpak.sh` (Flatpak + Flathub), `install-telegram.sh`, `install-discord.sh`, `install-steam.sh`
#   - Located in `workflows/`
# sudo: false
# interactive: false
# idempotent: true
# dependencies: standalone/apt/cli/install-flatpak.sh, standalone/flatpak/install-telegram.sh, standalone/flatpak/install-discord.sh, standalone/flatpak/install-steam.sh
# ---DOC-END---

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

APT_CLI_DIR="$(cd "$SCRIPT_DIR/../standalone/apt/cli" && pwd)"
FLATPAK_DIR="$(cd "$SCRIPT_DIR/../standalone/flatpak" && pwd)"

echo "[*] Running install-flatpak.sh"
bash "$APT_CLI_DIR/install-flatpak.sh"

for script in install-telegram.sh install-discord.sh install-steam.sh; do
    echo "[*] Running $script"
    bash "$FLATPAK_DIR/$script"
done

echo "[+] Done."
