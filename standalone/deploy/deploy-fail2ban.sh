#!/bin/bash

# ---DOC-START---
# summary: Install and configure Fail2Ban for SSH protection.
# description: |
#   Installs and configures **Fail2Ban** with a basic SSH jail.
#
#   - Installs `fail2ban`
#   - Creates `/etc/fail2ban/jail.local`
#   - Enables the `sshd` jail
#   - Enables and starts the `fail2ban` service
#   - Validates the configuration before restarting the service
#   - Prints a deployment summary
#
#   Existing `jail.local` will be replaced.
# sudo: true
# interactive: false
# idempotent: mostly
# dependencies: none
# ---DOC-END---

set -euo pipefail
export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"

if [[ $EUID -ne 0 ]]; then
    echo "[!] Please log in as root and run this script."
    exit 1
fi

echo "==> Installing dependencies"

echo "[*] Updating system packages..."
apt-get update

echo "[*] Installing Fail2Ban..."
apt-get install -y fail2ban

echo "==> Configuring Fail2Ban"

cat >/etc/fail2ban/jail.local <<'EOF'
[DEFAULT]
bantime = 1h
findtime = 10m
maxretry = 5
backend = systemd

[sshd]
enabled = true
EOF

echo "==> Validation"

if fail2ban-client -t >/dev/null 2>&1; then
    echo "[+] Fail2Ban configuration is valid."
else
    echo "//////////////////////////////////////////////////"
    echo "Configuration error found."
    echo "Fail2Ban service was NOT started."
    echo "//////////////////////////////////////////////////"
    exit 1
fi

echo "[*] Enabling Fail2Ban service..."
systemctl enable fail2ban

echo "[*] Restarting Fail2Ban service..."
systemctl restart fail2ban

FAIL2BAN_STATUS=$(systemctl is-active fail2ban)
FAIL2BAN_ENABLED=$(systemctl is-enabled fail2ban)

echo ""
echo "==> Summary"
echo ""
echo "Fail2Ban Information:"
echo "  Service:          fail2ban"
echo "  Status:           $FAIL2BAN_STATUS"
echo "  Startup:          $FAIL2BAN_ENABLED"
echo "  Config:           /etc/fail2ban/jail.local"
echo ""

echo "Active Jails:"
fail2ban-client status

echo ""
echo "[+] Fail2Ban deployed successfully."
