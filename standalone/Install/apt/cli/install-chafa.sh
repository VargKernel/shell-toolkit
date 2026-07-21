#!/bin/bash

# ---DOC-START---
# summary: Install chafa (terminal image/GIF viewer) from the distribution repositories.
# description: |
#   Installs [chafa](https://github.com/hpjansson/chafa) via apt.
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

echo "==> Installing chafa"

if command -v chafa >/dev/null 2>&1; then
    echo "[i] chafa is already installed, skipping..."
    exit 0
fi

echo "[*] Updating package lists..."
apt update -q

echo "[*] Installing chafa..."
apt install -y chafa

echo ""
echo "[+] chafa installed successfully."
