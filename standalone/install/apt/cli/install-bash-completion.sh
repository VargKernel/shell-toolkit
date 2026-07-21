#!/bin/bash

# ---DOC-START---
# summary: Install bash-completion from the distribution repositories.
# description: |
#   Installs [bash-completion](https://github.com/scop/bash-completion) via apt.
#   Programmable completion is normally auto-sourced by `/etc/bash.bashrc` on
#   Debian/Ubuntu once the package is present — no manual .bashrc edit needed.
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

echo "==> Installing bash-completion"

if dpkg -s bash-completion >/dev/null 2>&1; then
    echo "[i] bash-completion is already installed, skipping..."
    exit 0
fi

echo "[*] Updating package lists..."
apt update -q

echo "[*] Installing bash-completion..."
apt install -y bash-completion

echo ""
echo "[+] bash-completion installed successfully."
echo "[i] Open a new shell (or 'source /etc/bash.bashrc') for completion to take effect."
