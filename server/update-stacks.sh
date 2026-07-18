#!/bin/bash

# ---DOC-START---
# summary: Pull and redeploy all Docker Compose stacks under `/opt/*`.
# description: |
#   Updates and redeploys every Docker Compose stack found under `/opt/*`.
#
#   - Lists currently running containers before starting
#   - Detects `docker-compose.yml`, `compose.yml`, `compose.yaml`, and `docker-compose.yaml`
#   - Runs `docker compose pull` followed by `docker compose up -d` for each stack
#   - Detects whether new images were actually pulled
#   - Skips directories with no compose file or where the pull fails
#   - Prints a final summary of updated, unchanged, and skipped stacks
# sudo: true
# interactive: false
# idempotent: true
# ---DOC-END---

set -euo pipefail
export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"

if [[ $EUID -ne 0 ]]; then
    echo "[!] Please log in as root and run this script."
    exit 1
fi

BASE_DIR="/opt"
UPDATED=()
UNCHANGED=()
SKIPPED=()

echo "----------------Current Containers---------------"
docker ps --format 'table {{.Names}}\t{{.Image}}\t{{.Status}}'

echo "-----------------Updating Stacks-----------------"

for dir in "$BASE_DIR"/*/; do
    stack="$(basename "$dir")"

    compose_file=""
    for f in docker-compose.yml compose.yml compose.yaml docker-compose.yaml; do
        if [[ -f "$dir$f" ]]; then
            compose_file="$f"
            break
        fi
    done

    if [[ -z "$compose_file" ]]; then
        echo "[i] $stack: no compose file found, skipping"
        SKIPPED+=("$stack")
        continue
    fi

    echo "[*] $stack: pulling images"
    pull_output="$(cd "$dir" && docker compose pull 2>&1)" || {
        echo "[!] $stack: pull failed"
        echo "$pull_output"
        SKIPPED+=("$stack")
        continue
    }

    # "up to date" lines mean no change for that image; anything else
    # ("Pulled", "Downloaded newer image", etc.) means an update happened
    if grep -qiE 'Pulled|Downloaded newer image' <<< "$pull_output"; then
        is_updated=true
    else
        is_updated=false
    fi

    echo "[*] $stack: applying (up -d)"
    (cd "$dir" && docker compose up -d) > /dev/null

    if [[ "$is_updated" == true ]]; then
        echo "[+] $stack: updated"
        UPDATED+=("$stack")
    else
        echo "[i] $stack: already up to date"
        UNCHANGED+=("$stack")
    fi
done

echo "---------------------Summary---------------------"
echo "[SUCCESS] Updated:   ${UPDATED[*]:-none}"
echo "          Unchanged: ${UNCHANGED[*]:-none}"
echo "          Skipped:   ${SKIPPED[*]:-none}"
