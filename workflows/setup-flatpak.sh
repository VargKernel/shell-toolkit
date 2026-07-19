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
# dependencies: standalone/flatpak/install-flatpak.sh, standalone/flatpak/install-telegram.sh, standalone/flatpak/install-discord.sh, standalone/flatpak/install-steam.sh
# ---DOC-END---

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FLATPAK_DIR="$(cd "$SCRIPT_DIR/../standalone/flatpak" && pwd)"

cd "$FLATPAK_DIR"

for script in install-flatpak.sh install-telegram.sh install-discord.sh install-steam.sh; do
    echo "[*] Running $script"
    bash "$script"
done

echo "[+] Done."
