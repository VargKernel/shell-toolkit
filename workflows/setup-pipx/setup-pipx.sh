#!/bin/bash

# ---DOC-START---
# summary: Install yt-dlp, gallery-dl, spotdl via pipx in one step.
# description: |
#   Installs a curated set of Python CLI tools via [pipx](https://github.com/pypa/pipx) in one step.
#
#   - Runs in order: `install-gallery-dl.sh`, `install-yt-dlp.sh`, `install-spotdl.sh`
#   - Located in `workflows/setup-pipx/`
# sudo: false
# interactive: false
# idempotent: true
# ---DOC-END---

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FLATPAK_DIR="$(cd "$SCRIPT_DIR/../../pipx" && pwd)"

cd "$FLATPAK_DIR"

for script in install-gallery-dl.sh install-yt-dlp.sh install-spotdl.sh; do
    echo "[*] Running $script"
    bash "$script"
done

echo "[+] Done."
