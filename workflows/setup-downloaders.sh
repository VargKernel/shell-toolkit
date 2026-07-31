#!/bin/bash

# ---DOC-START---
# summary: Install yt-dlp, gallery-dl, spotdl via pipx in one step.
# description: |
#   Installs a curated set of Python CLI tools via [pipx](https://github.com/pypa/pipx) in one step.
#
#   - Runs in order: `install-pipx.sh`, `install-gallery-dl.sh`, `install-yt-dlp.sh`, `install-spotdl.sh`
# sudo: false
# interactive: false
# idempotent: true
# dependencies: standalone/install/apt/cli/install-pipx.sh, standalone/install/pipx/install-gallery-dl.sh, standalone/install/pipx/install-yt-dlp.sh, standalone/install/pipx/install-spotdl.sh
# ---DOC-END---

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

APT_CLI_DIR="$(cd "$SCRIPT_DIR/../standalone/install/apt/cli" && pwd)"
PIPX_DIR="$(cd "$SCRIPT_DIR/../standalone/install/pipx" && pwd)"

echo "Running install-pipx.sh"
bash "$APT_CLI_DIR/install-pipx.sh"

for script in install-gallery-dl.sh install-yt-dlp.sh install-spotdl.sh; do
    echo "Running $script"
    bash "$PIPX_DIR/$script"
done

echo "Done."
