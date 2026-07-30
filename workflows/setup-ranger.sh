#!/bin/bash

# ---DOC-START---
# summary: Install and configure ranger with Nerd Fonts and ranger_devicons.
# description: |
#   Installs a complete ranger environment by chaining standalone scripts.
#
#   - Installs ranger.
#   - Installs popular Nerd Fonts.
#   - Installs and configures ranger_devicons.
#   - Each subscript is executed individually so failures are isolated and traceable.
#
#   Workflow must be started as a regular user.
#   Individual scripts handle privilege escalation when required.
# sudo: false
# interactive: false
# idempotent: true
# dependencies: standalone/install/apt/cli/install-ranger.sh, standalone/install/install-nerd-fonts.sh, standalone/install/install-ranger-devicons.sh
# ---DOC-END---

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INSTALL_DIR="$(cd "$SCRIPT_DIR/../standalone/install" && pwd)"

run_script() {
    local script="$1"

    if [[ ! -f "$script" ]]; then
        echo "Missing $script"
        return 1
    fi

    echo "Running $(basename "$script")"
    bash "$script"
}

echo "Running ranger setup..."

run_script "$INSTALL_DIR/apt/cli/install-ranger.sh"
run_script "$INSTALL_DIR/install-nerd-fonts.sh"
run_script "$INSTALL_DIR/install-ranger-devicons.sh"

echo "Done."
