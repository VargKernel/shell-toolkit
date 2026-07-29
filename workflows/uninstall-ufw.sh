#!/bin/bash

# ---DOC-START---
# summary: Disable and uninstall UFW.
# description: |
#   Disables UFW and removes the package.
#
#   - Runs in order: `disable-ufw.sh`, `remove-ufw.sh`
#   - Each subscript is executed individually so a failure is isolated and traceable
#   - Located in `workflows/`
# sudo: true
# interactive: false
# idempotent: true
# dependencies: standalone/firewall/disable-ufw.sh, standalone/firewall/remove-ufw.sh
# ---DOC-END---

set -euo pipefail
export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"

if [[ $EUID -ne 0 ]]; then
    echo "Please log in as root and run this script."
    exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

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

echo "Running UFW uninstallation..."

run_scripts "$FIREWALL_DIR" \
    disable-ufw.sh \
    remove-ufw.sh

echo "Done."
