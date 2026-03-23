#!/bin/bash
# =============================================================================
# ACME IT Corp - UFW Firewall Rules
# =============================================================================
# Layered on top of iptables. UFW provides a simpler management interface
# and adds explicit allow rules for lab services plus the internal network.
#
# Run independently:  sudo ./defenses/ufw.sh
# Called by:          setup.sh
#
# Requires: defenses/iptables.sh should run first
#
# ⚠️  CONFLICT: Arbitrary outbound ports (e.g. 4444 for reverse shells) are
#     not explicitly allowed. If a reverse shell isn't connecting, check
#     `sudo ufw status` and add a temporary rule if needed.
# =============================================================================

set -euo pipefail

echo "[ufw] Configuring UFW rules..."

# -----------------------------------------------------------------------------
# Set default policies
# -----------------------------------------------------------------------------
ufw default deny incoming
ufw default allow outgoing

# -----------------------------------------------------------------------------
# Allow lab service ports
# -----------------------------------------------------------------------------
ufw allow 22/tcp    # SSH
ufw allow 80/tcp    # HTTP
ufw allow 3000/tcp  # Next.js dashboard

# -----------------------------------------------------------------------------
# Allow all traffic from the internal lab network (172.16.0.0/24)
# This covers FTP server communication and inter-VM traffic
# -----------------------------------------------------------------------------
ufw allow from 172.16.0.0/24

# -----------------------------------------------------------------------------
# Enable UFW (non-interactive)
# -----------------------------------------------------------------------------
ufw --force enable

echo "[ufw] UFW enabled."
ufw status verbose