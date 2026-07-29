#!/bin/bash

# ---DOC-START---
# summary: Install and enable UFW.
# description: |
#   Installs UFW and enables the firewall.
#
#   - Runs in order: `install-ufw.sh`, `enable-ufw.sh`
#   - Each subscript is executed individually so a failure is isolated and traceable
#   - Located in `workflows/`
# sudo: true
# interactive: false
# idempotent: true
# dependencies: standalone/install/apt/cli/install-ufw.sh, standalone/firewall/enable-ufw.sh
# ---DOC-END---

set -euo pipefail
export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"

if [[ $EUID -ne 0 ]]; then
    echo "Please log in as root and run this script."
    exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

INSTALL_DIR="$(cd "$SCRIPT_DIR/../standalone/install/apt/cli" && pwd)"
FIREWALL_DIR="$(cd "$SCRIPT_DIR/../standalone/firewall" && pwd)"

run_scripts() {
    local dir="$1"
    shift
    local scripts=("$@")

    cd "$dir"

    for script in "${scripts[@]}"; do
        if [[ -f "$script" ]]; then
            echo "Running $script"
            bash "$script"
        else
            echo "Missing $script in $dir"
        fi
    done
}

echo "Running UFW setup..."

run_scripts "$INSTALL_DIR" \
    install-ufw.sh

run_scripts "$FIREWALL_DIR" \
    enable-ufw.sh

echo "Done."
