#!/bin/bash

# ---DOC-START---
# summary: Disable and remove Firewalld.
# description: |
#   Disables and completely removes **Firewalld**.
#
#   - Stops the Firewalld service
#   - Disables Firewalld from starting at boot
#   - Removes the Firewalld package
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

if ! command -v firewall-cmd >/dev/null 2>&1; then
    echo "[INFO] Firewalld is not installed. Nothing to do."
    exit 0
fi

echo "[*] Stopping Firewalld..."
systemctl stop firewalld || true

echo "[*] Disabling Firewalld..."
systemctl disable firewalld || true

echo "[*] Removing Firewalld..."
apt-get remove -y firewalld

echo "[*] Removing unused dependencies..."
apt-get autoremove -y

echo "[SUCCESS] Firewalld has been removed."
