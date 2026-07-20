#!/bin/bash

# ---DOC-START---
# summary: Install yt-dlp, gallery-dl, spotdl via pipx in one step.
# description: |
#   Installs a curated set of Python CLI tools via [pipx](https://github.com/pypa/pipx) in one step.
#
#   - Runs in order: `install-pipx.sh`, `install-gallery-dl.sh`, `install-yt-dlp.sh`, `install-spotdl.sh`
#   - Located in `workflows/`
# sudo: false
# interactive: false
# idempotent: true
# dependencies: standalone/apt/cli/install-pipx.sh, standalone/pipx/install-gallery-dl.sh, standalone/pipx/install-yt-dlp.sh, standalone/pipx/install-spotdl.sh
# ---DOC-END---

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

APT_CLI_DIR="$(cd "$SCRIPT_DIR/../standalone/apt/cli" && pwd)"
PIPX_DIR="$(cd "$SCRIPT_DIR/../standalone/pipx" && pwd)"

echo "[*] Running install-pipx.sh"
bash "$APT_CLI_DIR/install-pipx.sh"

for script in install-gallery-dl.sh install-yt-dlp.sh install-spotdl.sh; do
    echo "[*] Running $script"
    bash "$PIPX_DIR/$script"
done

echo "[+] Done."
