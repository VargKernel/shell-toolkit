#!/bin/bash

# ---DOC-START---
# summary: Install the Kate text editor and official plugins.
# description: |
#   Installs the [Kate](https://kate-editor.org) text editor along with the
#   official plugin collection (`kate-plugins`).
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

echo "[*] Updating package lists..."
apt update

echo "[*] Installing Kate..."
apt install -y \
    kate \
    kate-plugins

echo "[+] Kate installed successfully."
