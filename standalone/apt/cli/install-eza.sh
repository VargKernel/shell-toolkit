#!/bin/bash

# ---DOC-START---
# summary: Install eza (modern ls replacement), adding the official apt repo if needed.
# description: |
#   Installs [eza](https://github.com/eza-community/eza) via apt.
#
#   - eza only reached Debian's own repos in Debian 13 (Trixie) / recent
#     Ubuntu. On releases where the apt package is unavailable, this script
#     adds the official third-party repository, `deb.gierens.de`
#     (https://eza.rocks / https://github.com/eza-community/eza/blob/main/INSTALL.md),
#     signed with its published GPG key, then installs from there.
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

echo "==> Installing eza"

if command -v eza >/dev/null 2>&1; then
    echo "[i] eza is already installed, skipping..."
    exit 0
fi

echo "[*] Updating package lists..."
apt update -q

if apt-cache show eza >/dev/null 2>&1; then
    echo "[*] Installing eza from the distribution repositories..."
    apt install -y eza
else
    echo "[i] eza package not found in configured repositories."
    echo "[*] Adding the official eza apt repository (deb.gierens.de)..."

    apt install -y gpg curl

    KEYRING="/etc/apt/keyrings/gierens.gpg"
    LIST="/etc/apt/sources.list.d/gierens.list"

    mkdir -p /etc/apt/keyrings
    curl -fsSL https://raw.githubusercontent.com/eza-community/eza/main/deb.asc \
        | gpg --dearmor -o "$KEYRING"
    echo "deb [signed-by=${KEYRING}] http://deb.gierens.de stable main" > "$LIST"
    chmod 644 "$KEYRING" "$LIST"

    echo "[*] Updating package lists..."
    apt update -q

    echo "[*] Installing eza..."
    apt install -y eza
fi

echo ""
echo "[+] eza installed successfully."
