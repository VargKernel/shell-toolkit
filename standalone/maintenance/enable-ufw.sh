#!/bin/bash

# ---DOC-START---
# summary: Enable UFW.
# description: |
#   Enables **UFW (Uncomplicated Firewall)**.
#
#   - Allows SSH before enabling the firewall to avoid locking out remote access.
#   - Enables UFW immediately.
#   - Note: if Firewalld is active, it should be disabled to avoid conflicting
#     netfilter rules; this script does not do that automatically.
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
    echo "[!] UFW is not installed."
    exit 1
fi

echo "[*] Allowing SSH..."
ufw allow OpenSSH

echo "[*] Enabling UFW..."
ufw --force enable

if systemctl is-active --quiet firewalld; then
    echo "[!] Firewalld is currently active. Running both Firewalld and UFW can"
    echo "    cause conflicting rules. Consider disabling Firewalld:"
    echo "    'sudo systemctl disable --now firewalld'"
fi

echo "[SUCCESS] UFW has been enabled."
