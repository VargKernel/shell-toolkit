#!/bin/bash

# ---DOC-START---
# summary: Remove UFW and replace it with Firewalld.
# description: |
#   Replaces UFW with **[Firewalld](https://firewalld.org)** on Debian/Ubuntu systems.
#
#   - Disables and removes UFW
#   - Installs Firewalld and enables it on boot
#   - Opens SSH in the default zone before finishing so the session is not dropped
#
#   > ⚠️ **Idempotency caveat:** safe to run on a system that still has UFW, but a no-op if UFW is already gone and Firewalld is already running — it will not reconfigure an existing Firewalld setup.
# sudo: true
# interactive: false
# idempotent: mostly
# dependencies: none
# ---DOC-END---

set -euo pipefail
export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"

if [[ $EUID -ne 0 ]]; then
    echo "[!] Please log in as root and run this script."
    exit 1
fi

if command -v ufw >/dev/null 2>&1; then
    echo "[*] Disabling UFW..."
    ufw disable || true

    echo "[*] Resetting UFW..."
    echo "y" | ufw reset

    echo "[*] Removing UFW..."
    apt-get remove -y ufw
    apt-get autoremove -y
fi

echo "[*] Updating package lists..."
apt-get update

echo "[*] Installing firewalld and OpenSSH Server..."
apt-get install -y firewalld openssh-server

echo "[*] Enabling and starting firewalld..."
systemctl enable --now firewalld

echo "[*] Enabling and starting SSH..."
systemctl enable --now ssh

echo "[*] Allowing SSH through firewalld..."
firewall-cmd --permanent --zone=public --add-service=ssh

echo "[*] Reloading firewall rules..."
firewall-cmd --reload

echo "[*] Verifying SSH service..."
if ! systemctl is-active --quiet ssh; then
    echo "[!] SSH service failed to start."
    exit 1
fi

echo "[*] Verifying that SSH is listening on port 22..."
if ! ss -tulpn | grep -q ':22'; then
    echo "[!] SSH is not listening on port 22."
    exit 1
fi

echo "[SUCCESS] Migration from UFW to firewalld completed successfully."
echo "          SSH is running and port 22 is allowed through the firewall."
