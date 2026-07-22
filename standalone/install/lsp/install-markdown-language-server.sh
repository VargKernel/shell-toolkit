#!/bin/bash

# ---DOC-START---
# summary: Install markdown-language-server via npm for editor/IDE LSP integration.
# description: |
#   Installs `markdown-language-server` via npm into `~/.local/npm`; adds to `~/.bashrc`.
#
#   - Idempotent — uses a marker block in `~/.bashrc` and skips installation if the server is already present
#   - Must be run as root so it can resolve the real user's home directory via `SUDO_USER`
# sudo: true
# interactive: false
# idempotent: true
# dependencies: none
# ---DOC-END---

set -euo pipefail
export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
export DEBIAN_FRONTEND=noninteractive

if [[ $EUID -ne 0 ]]; then
    echo "[!] Please log in as root and run this script."
    exit 1
fi

echo "==> Installing Markdown LSP"

# --- detect real user home ---
REAL_USER="${SUDO_USER:-root}"
REAL_HOME="$(eval echo "~$REAL_USER")"

MARK_START="# >>> markdown-language-server >>>"
MARK_END="# <<< markdown-language-server <<<"

INSTALL_DIR="$REAL_HOME/.local/bin"
mkdir -p "$INSTALL_DIR"

chown -R "$REAL_USER:$REAL_USER" "$REAL_HOME/.local" 2>/dev/null || true

# --- install curl if missing ---
if ! command -v curl >/dev/null 2>&1; then
    echo "[*] Installing curl..."
    apt-get update
    apt-get install -y curl
fi

# --- install marksman ---
if ! command -v "$INSTALL_DIR/marksman" >/dev/null 2>&1; then
    echo "[*] Installing marksman (Markdown LSP)..."

    TMP_DIR="$(mktemp -d)"
    trap 'rm -rf "$TMP_DIR"' EXIT
    cd "$TMP_DIR"

    curl -L -o marksman https://github.com/artempyanykh/marksman/releases/latest/download/marksman-linux-x64
    chmod +x marksman
    mv marksman "$INSTALL_DIR/marksman"
fi

# --- bashrc ---
grep -qF "$MARK_START" "$REAL_HOME/.bashrc" || cat >> "$REAL_HOME/.bashrc" <<EOF

$MARK_START
export PATH="\$HOME/.local/bin:\$PATH"
$MARK_END
EOF

# --- profile ---
grep -qF "$MARK_START" "$REAL_HOME/.profile" || cat >> "$REAL_HOME/.profile" <<EOF

$MARK_START
export PATH="\$HOME/.local/bin:\$PATH"
$MARK_END
EOF

chown "$REAL_USER:$REAL_USER" "$REAL_HOME/.bashrc" "$REAL_HOME/.profile" 2>/dev/null || true

echo ""
echo "[+] Markdown LSP installed successfully."
echo ""
echo "[NOTE] Log out and log back into your session"
echo "       (or reboot) for the updated PATH to take effect."
