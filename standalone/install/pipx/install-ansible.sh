#!/bin/bash

# ---DOC-START---
# summary: Install Ansible via pipx.
# description: |
#   Installs the latest Ansible with all CLI applications exposed
#   (ansible-playbook, ansible-galaxy, ansible-vault, etc.) using pipx.
#
#   If an older pipx installation exists, it is removed first to ensure
#   the full CLI is installed with --include-deps.
# sudo: false
# interactive: false
# idempotent: true
# dependencies: pipx
# ---DOC-END---

set -euo pipefail

export PATH="$HOME/.local/bin:$PATH"

echo "[*] Installing Ansible via pipx..."

if pipx list 2>/dev/null | grep -q "^package ansible "; then
    echo "[i] Existing Ansible installation found, reinstalling..."
    pipx uninstall ansible
fi

pipx install --include-deps ansible

echo "[+] Ansible installed"
