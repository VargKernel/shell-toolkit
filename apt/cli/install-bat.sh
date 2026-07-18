#!/bin/bash
# ---DOC-START---
# summary: Install bat (cat clone with syntax highlighting) from the distribution repositories.
# description: |
#   Installs [bat](https://github.com/sharkdp/bat) via apt.
#
#   - On Ubuntu/Debian the binary ships as `batcat` (to avoid a name clash
#     with an unrelated `bat` package). This script adds a `bat` symlink to
#     `/usr/local/bin/bat` when only `batcat` is present, so `bat` works
#     out of the box.
# sudo: true
# interactive: false
# idempotent: true
# ---DOC-END---
set -euo pipefail
export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
export DEBIAN_FRONTEND=noninteractive

if [[ $EUID -ne 0 ]]; then
    echo "[!] Please log in as root and run this script."
    exit 1
fi

echo "------------------Installing bat------------------"

if command -v bat >/dev/null 2>&1; then
    echo "[i] bat is already installed, skipping."
    exit 0
fi

echo "[*] Updating package lists..."
apt update -q

echo "[*] Installing bat..."
apt install -y bat

if ! command -v bat >/dev/null 2>&1 && command -v batcat >/dev/null 2>&1; then
    echo "[*] Linking batcat -> /usr/local/bin/bat..."
    ln -sf "$(command -v batcat)" /usr/local/bin/bat
fi

echo ""
echo "[+] bat installed successfully."
