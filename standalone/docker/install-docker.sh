#!/bin/bash

# ---DOC-START---
# summary: Install Docker Engine and the Docker Compose plugin.
# description: |
#   Installs [Docker](https://www.docker.com) Engine (`docker.io`) and the Docker Compose plugin; enables and starts the service.
# sudo: true
# interactive: false
# idempotent: mostly
# dependencies: none
# ---DOC-END---

set -euo pipefail
export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
export DEBIAN_FRONTEND=noninteractive

if [[ $EUID -ne 0 ]]; then
    echo "[!] Please log in as root and run this script."
    exit 1
fi

echo "==> Installing Installing Docker Engine (docker.io) and Docker Compose plugin"

echo "[*] Updating package lists..."
apt update -q

echo "[*] Installing Docker Engine (docker.io) and Docker Compose plugin..."
apt install -y docker.io docker-compose

echo "[*] Enabling and starting Docker service..."
systemctl enable --now docker

echo "[*] Verifying installation..."
docker --version
docker compose version

echo "[+] Docker and Docker Compose installed successfully."
