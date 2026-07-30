#!/bin/bash

# ---DOC-START---
# summary: Install a full C++/Python/PHP/Node dev environment + LSP servers in one step.
# description: |
#   Installs a complete development environment by chaining scripts from `apt/` and `lsp/`.
#
#   - Runs in order: `install-cpp.sh`, `install-python.sh`, `install-php.sh`, `install-kate.sh`, `install-kdevelop.sh`, `install-npm.sh`, `install-ghostwriter.sh`, `install-docker.sh`
#   - Then installs `install-bash-language-server.sh`, `install-markdown-language-server.sh` and `install-python-language-server.sh`
# sudo: false
# interactive: false
# idempotent: true
# dependencies: standalone/install/apt/cli/install-cpp.sh, standalone/install/apt/cli/install-python.sh, standalone/install/apt/cli/install-php.sh, standalone/install/apt/cli/install-npm.sh, standalone/install/apt/cli/install-docker.sh, standalone/install/apt/gui/install-kate.sh, standalone/install/apt/gui/install-kdevelop.sh, standalone/install/apt/gui/install-ghostwriter.sh, standalone/install/lsp/install-bash-language-server.sh, standalone/install/lsp/install-markdown-language-server.sh, standalone/install/lsp/install-python-language-server.sh
# ---DOC-END---

set -euo pipefail
export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"

run_root_scripts() {
    local dir="$1"
    shift

    for script in "$@"; do
        echo "Running $script"
        sudo bash "$dir/$script"
    done
}

run_user_scripts() {
    local dir="$1"
    shift

    for script in "$@"; do
        echo "Running $script"
        bash "$dir/$script"
    done
}

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

CLI_DIR="$(cd "$SCRIPT_DIR/../standalone/install/apt/cli" && pwd)"
GUI_DIR="$(cd "$SCRIPT_DIR/../standalone/install/apt/gui" && pwd)"
LSP_DIR="$(cd "$SCRIPT_DIR/../standalone/install/lsp" && pwd)"

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

echo "Running CLI installation scripts..."
run_root_scripts "$CLI_DIR" \
    install-cpp.sh \
    install-python.sh \
    install-php.sh \
    install-npm.sh \
    install-docker.sh

echo "Running GUI installation scripts..."
run_root_scripts "$GUI_DIR" \
    install-kate.sh \
    install-kdevelop.sh \
    install-ghostwriter.sh

echo "Running LSP installation scripts..."
run_user_scripts "$LSP_DIR" \
    install-bash-language-server.sh \
    install-markdown-language-server.sh \
    install-python-language-server.sh

echo "Done."
