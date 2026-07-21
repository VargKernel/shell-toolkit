#!/bin/bash

# ---DOC-START---
# summary: Clear cache, cookies, and history for Firefox.
# description: |
# Stops Firefox and clears cookies, history, cache, session data.
# sudo: false
# interactive: false
# idempotent: true
# dependencies: none
# ---DOC-END---

set -euo pipefail
export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"

echo "[*] Stopping Firefox (if running)..."
pkill firefox || true

echo "[*] Cleaning Firefox..."
FIREFOX_DIR="$HOME/.mozilla/firefox"
if [[ -d "$FIREFOX_DIR" ]]; then
    find "$FIREFOX_DIR" -type f \( \
        -name "places.sqlite" \
        -o -name "cookies.sqlite" \
        -o -name "favicons.sqlite" \
    \) -delete
    rm -rf "$HOME/.cache/mozilla/firefox"/* 2>/dev/null || true
    echo "[+] Firefox cleaned."
else
    echo "[-] Firefox not found."
fi
