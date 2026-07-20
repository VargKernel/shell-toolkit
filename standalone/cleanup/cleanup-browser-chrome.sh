#!/bin/bash

# ---DOC-START---
# summary: Clear cache, cookies, and history for Google Chrome.
# description: |
# Stops Chrome and clears cookies, history, cache, etc.
# sudo: false
# interactive: false
# idempotent: true
# dependencies: none
# ---DOC-END---

set -euo pipefail
export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"

echo "[*] Stopping Chrome (if running)..."
pkill chrome || true

echo "[*] Cleaning Google Chrome..."
CHROME_DIR="$HOME/.config/google-chrome"
if [[ -d "$CHROME_DIR" ]]; then
    find "$CHROME_DIR" -type f \( \
        -name "History" \
        -o -name "Cookies" \
        -o -name "Top Sites" \
        -o -name "Favicons" \
        -o -name "Visited Links" \
        -o -name "History-journal" \
        -o -name "History-wal" \
    \) -delete
    rm -rf "$HOME/.cache/google-chrome"/* 2>/dev/null || true
    echo "[+] Google Chrome cleaned."
else
    echo "[-] Google Chrome not found."
fi
