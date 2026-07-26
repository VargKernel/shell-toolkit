#!/bin/bash

# ---DOC-START---
# summary: Install Ansible and related tools.
# description: |
#   Installs Ansible (Ansible Core) and Ansible Lint.
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

echo "==> Installing Ansible"

echo "[*] Updating package lists..."
apt update -q

echo "[*] Installing Ansible and related tools..."
apt install -y \
    ansible \
    ansible-core \
    ansible-lint

echo ""
echo "[+] Ansible installed successfully."
