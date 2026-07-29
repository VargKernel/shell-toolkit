#!/bin/bash

# ---DOC-START---
# summary: Install the KDevelop IDE.
# description: |
#   Installs the [KDevelop](https://kdevelop.org) IDE.
# sudo: true
# interactive: false
# idempotent: true
# dependencies: none
# ---DOC-END---

set -euo pipefail
export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
export DEBIAN_FRONTEND=noninteractive

if [[ $EUID -ne 0 ]]; then
    echo "Please log in as root and run this script."
    exit 1
fi

echo "==> Installing kdevelop"

echo "Updating package lists..."
apt update -q

echo "Installing kdevelop..."
apt install -y \
    git \
    kdevelop \
    kdevelop-python \
    kdevelop-php

echo ""
echo "Development tools installed successfully."
