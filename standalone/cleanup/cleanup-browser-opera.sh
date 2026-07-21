#!/bin/bash

# ---DOC-START---
# summary: Clear cache, cookies, and history for Opera.
# description: |
# Stops Opera and clears cookies, history, cache, etc.
# sudo: false
# interactive: false
# idempotent: true
# dependencies: none
# ---DOC-END---

set -euo pipefail
export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"

echo "[*] Stopping Opera (if running)..."
pkill opera || true

echo "[*] Cleaning Opera..."
OPERA_DIR="$HOME/.config/opera"
if [[ -d "$OPERA_DIR" ]]; then
    find "$OPERA_DIR" -type f \( \
        -name "History" \
        -o -name "Cookies" \
        -o -name "Visited Links" \
    \) -delete
    rm -rf "$HOME/.cache/opera"/* 2>/dev/null || true
    echo "[+] Opera cleaned."
else
    echo "[-] Opera not found."
fi
