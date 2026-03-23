#!/bin/bash
# =============================================================================
# ACME IT Corp - iptables Firewall Rules
# =============================================================================
# Configures iptables INPUT chain with:
#   - Allow established/related connections
#   - Allow loopback
#   - Allow SSH (22), HTTP (80), dashboard (3000)
#   - SYN rate limiting (slows nmap, makes timing unreliable)
#   - ICMP rate limiting (slows ping sweeps)
#   - Drop NULL and XMAS scan packets silently
#
# Rules are persisted via netfilter-persistent.
#
# Run independently:  sudo ./defenses/iptables.sh
# Called by:          setup.sh
#
# ⚠️  CONFLICT: SYN rate limiting may interfere with reverse shells on
#     non-standard ports. See defenses/README.md for details.
# =============================================================================

set -euo pipefail

echo "[iptables] Applying firewall rules..."

# -----------------------------------------------------------------------------
# Flush existing INPUT rules to start clean
# -----------------------------------------------------------------------------
iptables -F INPUT

# -----------------------------------------------------------------------------
# Allow established and related connections (stateful)
# -----------------------------------------------------------------------------
iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT

# -----------------------------------------------------------------------------
# Allow loopback interface
# -----------------------------------------------------------------------------
iptables -A INPUT -i lo -j ACCEPT

# -----------------------------------------------------------------------------
# Allow specific service ports
# -----------------------------------------------------------------------------
iptables -A INPUT -p tcp --dport 22 -j ACCEPT    # SSH
iptables -A INPUT -p tcp --dport 80 -j ACCEPT    # HTTP / Apache
iptables -A INPUT -p tcp --dport 3000 -j ACCEPT  # Next.js dashboard

# -----------------------------------------------------------------------------
# SYN rate limiting — makes nmap timing unreliable, slows scans
# Allow up to 20 new connections in a burst, then 10/second
# -----------------------------------------------------------------------------
iptables -A INPUT -p tcp --syn -m limit --limit 10/second --limit-burst 20 -j ACCEPT
iptables -A INPUT -p tcp --syn -j DROP

# -----------------------------------------------------------------------------
# ICMP rate limiting — slows ping sweeps
# Allow up to 5 pings in a burst, then 1/second
# -----------------------------------------------------------------------------
iptables -A INPUT -p icmp --icmp-type echo-request -m limit --limit 1/second --limit-burst 5 -j ACCEPT
iptables -A INPUT -p icmp --icmp-type echo-request -j DROP

# -----------------------------------------------------------------------------
# Drop stealth scan packets silently
# NULL scan: no flags set
# XMAS scan: all flags set
# -----------------------------------------------------------------------------
iptables -A INPUT -p tcp --tcp-flags ALL NONE -j DROP
iptables -A INPUT -p tcp --tcp-flags ALL ALL -j DROP

# -----------------------------------------------------------------------------
# Persist rules across reboots
# -----------------------------------------------------------------------------
apt install -y iptables-persistent -q
netfilter-persistent save

echo "[iptables] Rules applied and saved."
echo "[iptables] Current INPUT chain:"
iptables -L INPUT -n --line-numbers