#!/bin/bash
# ---DOC-START---
# summary: Install htop from the distribution repositories.
# description: |
#   Installs [htop](https://htop.dev) via apt.
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

echo "-----------------Installing htop-----------------"

if command -v htop >/dev/null 2>&1; then
    echo "[i] htop is already installed, skipping."
    exit 0
fi

echo "[*] Updating package lists..."
apt update -q

echo "[*] Installing htop..."
apt install -y htop

echo ""
echo "[+] htop installed successfully."
