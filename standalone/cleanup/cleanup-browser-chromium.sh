#!/bin/bash

# ---DOC-START---
# summary: Clear cache, cookies, and history for Chromium.
# description: |
# Stops Chromium and clears cookies, history, cache, etc.
# sudo: false
# interactive: false
# idempotent: true
# dependencies: none
# ---DOC-END---

set -euo pipefail
export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"

echo "[*] Stopping Chromium (if running)..."
pkill chromium || true

echo "[*] Cleaning Chromium..."
CHROMIUM_DIR="$HOME/.config/chromium"
if [[ -d "$CHROMIUM_DIR" ]]; then
    find "$CHROMIUM_DIR" -type f \( \
        -name "History" \
        -o -name "Cookies" \
        -o -name "Top Sites" \
        -o -name "Favicons" \
        -o -name "Visited Links" \
    \) -delete
    rm -rf "$HOME/.cache/chromium"/* 2>/dev/null || true
    echo "[+] Chromium cleaned."
else
    echo "[-] Chromium not found."
fi
