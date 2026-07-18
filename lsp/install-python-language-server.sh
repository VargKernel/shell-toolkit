#!/bin/bash

# ---DOC-START---
# summary: Install python-lsp-server (pylsp) via pipx for editor/IDE LSP integration.
# description: |
#   Installs [python-lsp-server](https://github.com/python-lsp/python-lsp-server) (`pylsp`)
#   for the current user, with all optional providers (Rope, Pyflakes, McCabe,
#   pycodestyle, pydocstyle, autopep8, YAPF) enabled via the `[all]` extra.
#
#   - Installs via `pipx`
#   - Adds `~/.local/bin` to PATH in `.bashrc` and `.profile`
#   - Idempotent — skips installation if `pylsp` is already available
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
if ! command -v pylsp >/dev/null 2>&1; then
    echo "[*] Installing python-lsp-server (pylsp)..."
    pipx install "python-lsp-server[all]"
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
