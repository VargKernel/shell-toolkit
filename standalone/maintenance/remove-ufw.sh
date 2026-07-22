#!/bin/bash

# ---DOC-START---
# summary: Disable and remove UFW.
# description: |
#   Disables and completely removes **UFW**.
#
#   - Disables the firewall if it is enabled
#   - Resets all UFW rules
#   - Removes the UFW package
#   - Removes automatically installed unused dependencies
#
#   Safe to run multiple times.
# sudo: true
# interactive: false
# idempotent: true
# dependencies: none
# ---DOC-END---

set -euo pipefail
export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"

if [[ $EUID -ne 0 ]]; then
    echo "[!] Please log in as root and run this script."
    exit 1
fi

if ! command -v ufw >/dev/null 2>&1; then
    echo "[INFO] UFW is not installed. Nothing to do."
    exit 0
fi

echo "[*] Disabling UFW..."
ufw disable || true

echo "[*] Resetting UFW..."
echo "y" | ufw reset

echo "[*] Removing UFW..."
apt-get remove -y ufw

echo "[*] Removing unused dependencies..."
apt-get autoremove -y

echo "[SUCCESS] UFW has been removed."
