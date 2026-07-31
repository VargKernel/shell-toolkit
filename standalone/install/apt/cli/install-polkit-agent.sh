#!/bin/bash
# ---DOC-START---
# summary: Install the polkit authentication agent.
# description: |
#   Installs `lxqt-policykit`.
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

echo "==> Installing polkit authentication agent"

echo "Updating package lists..."
apt update -q

echo "Installing polkit authentication agent..."
apt install -y \
    lxqt-policykit

echo ""
echo "polkit authentication agent installed successfully."
