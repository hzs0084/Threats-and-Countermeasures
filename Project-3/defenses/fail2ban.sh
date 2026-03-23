#!/bin/bash
# =============================================================================
# ACME IT Corp - fail2ban SSH Brute-Force Protection
# =============================================================================
# Installs fail2ban and enables the SSH jail. Bans source IPs after 5 failed
# authentication attempts within 10 minutes for 10 minutes.
#
# Run independently:  sudo ./defenses/fail2ban.sh
# Called by:          setup.sh
#
# Log to watch:  /var/log/fail2ban.log
# Check status:  sudo fail2ban-client status sshd
# =============================================================================

set -euo pipefail

echo "[fail2ban] Installing fail2ban..."

apt install -y fail2ban

# -----------------------------------------------------------------------------
# Local jail configuration — overrides /etc/fail2ban/jail.conf safely
# Using jail.local so package upgrades don't clobber our settings
# -----------------------------------------------------------------------------
cat > /etc/fail2ban/jail.local << 'EOF'
[DEFAULT]
# Ban duration: 10 minutes
bantime  = 600
# Detection window: 10 minutes
findtime = 600
# Max failures before ban
maxretry = 5

[sshd]
enabled  = true
port     = ssh
logpath  = %(sshd_log)s
backend  = %(sshd_backend)s
EOF

systemctl enable fail2ban
systemctl restart fail2ban

echo "[fail2ban] fail2ban running."
echo "[fail2ban] SSH jail enabled: 5 failures in 10 min = 10 min ban."
echo "[fail2ban] Check status: sudo fail2ban-client status sshd"
echo "[fail2ban] Watch log:    sudo tail -f /var/log/fail2ban.log"