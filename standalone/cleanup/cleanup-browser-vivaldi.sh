#!/bin/bash

# ---DOC-START---
# summary: Clear cache, cookies, and history for Vivaldi.
# description: |
# Stops Vivaldi and clears cookies, history, cache, etc.
# sudo: false
# interactive: false
# idempotent: true
# dependencies: none
# ---DOC-END---

set -euo pipefail
export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"

echo "[*] Stopping Vivaldi (if running)..."
pkill vivaldi || true

echo "[*] Cleaning Vivaldi..."
VIVALDI_DIR="$HOME/.config/vivaldi"
if [[ -d "$VIVALDI_DIR" ]]; then
    find "$VIVALDI_DIR" -type f \( \
        -name "History" \
        -o -name "Cookies" \
        -o -name "Top Sites" \
        -o -name "Favicons" \
        -o -name "Visited Links" \
    \) -delete
    rm -rf "$HOME/.cache/vivaldi"/* 2>/dev/null || true
    echo "[+] Vivaldi cleaned."
else
    echo "[-] Vivaldi not found."
fi
