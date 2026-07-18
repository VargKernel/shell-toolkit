#!/bin/bash

# ---DOC-START---
# summary: Install python-lsp-server (pylsp) via pip for editor/IDE LSP integration.
# description: |
#   Installs [python-lsp-server](https://github.com/python-lsp/python-lsp-server) (`pylsp`)
#   for the current user, with all optional providers (Rope, Pyflakes, McCabe,
#   pycodestyle, pydocstyle, autopep8, YAPF) enabled via the `[all]` extra.
#
#   - Installs into `~/.local/bin` via `pip install --user`, then adds it to `~/.bashrc`
#   - Falls back to `--break-system-packages` automatically on distros that mark the
#     system Python as externally managed (PEP 668, e.g. Debian 12+/Ubuntu 23.04+)
#   - Idempotent — skips installation if `pylsp` is already present in `~/.local/bin`
# sudo: false
# interactive: false
# idempotent: true
# ---DOC-END---

set -euo pipefail

MARK_START="# >>> python-language-server >>>"
MARK_END="# <<< python-language-server <<<"

INSTALL_DIR="$HOME/.local/bin"
mkdir -p "$INSTALL_DIR"

# --- install pylsp ---
if ! command -v "$INSTALL_DIR/pylsp" >/dev/null 2>&1; then
    echo "[*] Installing python-lsp-server (pylsp)..."

    PIP_LOG="$(mktemp)"
    trap 'rm -f "$PIP_LOG"' EXIT

    if ! python3 -m pip install --user --quiet "python-lsp-server[all]" >"$PIP_LOG" 2>&1; then
        if grep -q "externally-managed-environment" "$PIP_LOG"; then
            echo "[*] Externally-managed environment detected, retrying with --break-system-packages..."
            python3 -m pip install --user --break-system-packages --quiet "python-lsp-server[all]"
        else
            cat "$PIP_LOG"
            exit 1
        fi
    fi
else
    echo "[*] pylsp already installed, skipping."
fi

# --- bashrc ---
grep -qF "$MARK_START" "$HOME/.bashrc" || cat >> "$HOME/.bashrc" <<EOF

$MARK_START
export PATH="\$HOME/.local/bin:\$PATH"
$MARK_END
EOF

# --- profile ---
grep -qF "$MARK_START" "$HOME/.profile" || cat >> "$HOME/.profile" <<EOF

$MARK_START
export PATH="\$HOME/.local/bin:\$PATH"
$MARK_END
EOF

echo "[NOTE] Log out and log back into your session"
echo "       (or reboot) for the updated PATH to take effect."
