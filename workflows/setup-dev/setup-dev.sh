#!/bin/bash

# ---DOC-START---
# summary: Install a full C++/Python/PHP/Node dev environment + LSP servers in one step.
# description: |
#   Installs a complete development environment by chaining scripts from `apt/` and `lsp/`.
#
#   - Runs in order: `install-cpp.sh`, `install-python.sh`, `install-php.sh`, `install-kdevelop.sh`, `install-npm.sh`, `install-ghostwriter.sh`, `install-docker.sh`
#   - Then installs `install-bash-language-server.sh` and `install-markdown-language-server.sh`
#   - Each subscript is executed individually so a failure is isolated and traceable
#   - Located in `workflows/setup-dev/`
# sudo: true
# interactive: false
# idempotent: true
# ---DOC-END---

set -euo pipefail
export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"

if [[ $EUID -ne 0 ]]; then
    echo "[!] Please log in as root and run this script."
    exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

CLI_DIR="$(cd "$SCRIPT_DIR/../../install/cli" && pwd)"
GUI_DIR="$(cd "$SCRIPT_DIR/../../install/gui" && pwd)"
LSP_DIR="$(cd "$SCRIPT_DIR/../../lsp" && pwd)"

run_scripts() {
    local dir="$1"
    shift
    local scripts=("$@")

    cd "$dir"

    for script in "${scripts[@]}"; do
        if [[ -f "$script" ]]; then
            echo "[*] Running $script"
            bash "$script"
        else
            echo "[!] Missing $script in $dir"
        fi
    done
}

echo "[*] Running CLI installation scripts..."
run_scripts "$CLI_DIR" \
    install-cpp.sh \
    install-python.sh \
    install-php.sh \
    install-npm.sh \
    install-docker.sh

echo "[*] Running GUI installation scripts..."
run_scripts "$GUI_DIR" \
    install-kdevelop.sh \
    install-ghostwriter.sh

echo "[*] Running LSP installation scripts..."
run_scripts "$LSP_DIR" \
    install-bash-language-server.sh \
    install-markdown-language-server.sh

echo "[+] Done."
