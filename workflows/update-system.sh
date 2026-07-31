#!/bin/bash

# ---DOC-START---
# summary: Update APT, Flatpak and pipx packages in one step.
# description: |
#   Updates all supported package managers by chaining standalone update scripts.
#
#   - Runs in order: `update-apt.sh`, `update-flatpak.sh`, `update-pipx.sh`
# sudo: false
# interactive: false
# idempotent: true
# dependencies: standalone/update/update-apt.sh, standalone/update/update-flatpak.sh, standalone/update/update-pipx.sh
# ---DOC-END---

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
UPDATE_DIR="$(cd "$SCRIPT_DIR/../standalone/update" && pwd)"

run_script() {
    local script="$1"

    if [[ ! -f "$script" ]]; then
        echo "Missing $script"
        return 1
    fi

    echo "Running $(basename "$script")"
    bash "$script"
}

echo "Running update scripts..."

run_script "$UPDATE_DIR/update-apt.sh"
run_script "$UPDATE_DIR/update-flatpak.sh"
run_script "$UPDATE_DIR/update-pipx.sh"

echo "Done."
