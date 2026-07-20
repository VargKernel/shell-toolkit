#!/bin/bash

# ---DOC-START---
# summary: Install kio-admin for Dolphin root access.
# description: |
#   Installs `kio-admin` for Dolphin root access.
# sudo: true
# interactive: false
# idempotent: mostly
# dependencies: none
# ---DOC-END---

set -euo pipefail
export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
export DEBIAN_FRONTEND=noninteractive

if [[ $EUID -ne 0 ]]; then
    echo "[!] Please log in as root and run this script."
    exit 1
fi

echo "==> Installing kio-admin"

# if command -v kio-admin >/dev/null 2>&1; then
#     echo "[i] kio-admin is already installed, skipping..."
#     exit 0
# fi

echo "[*] Updating package lists..."
apt update -q

echo "[*] Installing kio-admin..."
apt install -y kio-admin

echo "[+] kio-admin installed successfully."
