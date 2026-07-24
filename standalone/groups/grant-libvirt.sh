#!/bin/bash

# ---DOC-START---
# summary: Add an existing user to the libvirt group.
# description: |
#   Adds an existing local user to the libvirt group required for managing
#   virtual machines with libvirt without root privileges.
#
#   Input (stdin):
#     1. Username
#
#   If stdin is not provided, the script prompts for the username.
#
#   Safe to re-run — users already in the libvirt group are skipped.
# sudo: true
# interactive: true
# idempotent: true
# dependencies: none
# ---DOC-END---

set -euo pipefail
export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"

if [[ $EUID -ne 0 ]]; then
    echo "[!] Please log in as root and run this script."
    exit 1
fi

echo "==> Grant libvirt access"

if ! getent group libvirt >/dev/null 2>&1; then
    echo "[!] libvirt group does not exist."
    echo "    Install the QEMU/KVM stack first."
    exit 1
fi

USERNAME=""

if read -r -t 0; then
    read -r USERNAME
else
    read -rp "[>] Username: " USERNAME
fi

if [[ -z "$USERNAME" ]]; then
    echo "[!] Username cannot be empty."
    exit 1
fi

if ! id "$USERNAME" &>/dev/null; then
    echo "[!] User '$USERNAME' does not exist."
    exit 1
fi

if getent group libvirt | grep -qw "$USERNAME"; then
    echo "[i] User '$USERNAME' is already a member of the libvirt group."
    exit 0
fi

echo "[*] Adding '$USERNAME' to libvirt group..."
usermod -aG libvirt "$USERNAME"

echo ""
echo "[+] User '$USERNAME' added to the libvirt group."
echo "[i] The user must log out and log back in for the new group membership to take effect."