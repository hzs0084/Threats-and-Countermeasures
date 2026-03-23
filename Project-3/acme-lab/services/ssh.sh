#!/bin/bash
# =============================================================================
# ACME IT Corp - OpenSSH Server Setup
# =============================================================================
# Ensures OpenSSH is installed and running. No hardening is applied here —
# this is intentionally left permissive for the lab (password auth enabled,
# root login permitted) to support brute-force exercises and Snort detection.
#
# Run independently:  sudo ./services/ssh.sh
# Called by:          setup.sh
#
# Port: 22
#
# ⚠️  NOTE: SSH brute force detection is handled by defenses/snort.sh (sid:1000013)
#     and defenses/fail2ban.sh. Deploy defenses after this script to observe alerts.
# =============================================================================

set -euo pipefail

echo "[ssh] Installing and configuring OpenSSH..."

apt install -y openssh-server

# -----------------------------------------------------------------------------
# Ensure password authentication is enabled (for brute-force exercise)
# -----------------------------------------------------------------------------
sed -i 's/^#\?PasswordAuthentication.*/PasswordAuthentication yes/' /etc/ssh/sshd_config
sed -i 's/^#\?PermitRootLogin.*/PermitRootLogin yes/' /etc/ssh/sshd_config

systemctl enable ssh
systemctl restart ssh

echo "[ssh] OpenSSH running on port 22."
echo "[ssh] Password authentication: enabled (intentional for lab exercises)."