#!/bin/bash
# =============================================================================
# ACME IT Corp - Bash History Injection (Scenario Artifacts)
# =============================================================================
# Plants fabricated .bash_history files for lab users. These are narrative
# artifacts — they simulate user activity for forensic exercises.
#
# Run independently:  sudo ./scenarios/inject_bash_histories.sh
# Called by:          setup.sh
#
# Requires: users/create_users.sh must have run first
#
# Safe to re-run: overwrites existing histories each time.
# Use this to reset scenario state after a student investigates.
# =============================================================================

set -euo pipefail

echo "[scenarios] Injecting bash histories..."

# -----------------------------------------------------------------------------
# Helper: write a history file with correct ownership and permissions
# -----------------------------------------------------------------------------
write_history() {
    local user="$1"
    local content="$2"
    local histfile="/home/${user}/.bash_history"

    echo "$content" | tee "$histfile" > /dev/null
    chown "${user}:${user}" "$histfile"
    chmod 600 "$histfile"
    echo "[scenarios]   Wrote history for: $user"
}

# -----------------------------------------------------------------------------
# Claire Redfield — FTP activity, browsed Documents
# Story: accessed internal FTP server (172.16.0.2), possible data access
# -----------------------------------------------------------------------------
write_history claireredfield "ls
cd Documents
cat Status_Update.txt
cd ..
ftp 172.16.0.2
cd /
ls
pwd
exit"

# -----------------------------------------------------------------------------
# Eve Johnson — disabled every defense on the system
# Story: deliberately killed Snort, fail2ban, UFW, and flushed iptables
#        Classic insider threat / compromised account pattern
# -----------------------------------------------------------------------------
write_history evejohnson "ls
sudo systemctl stop snort
sudo systemctl stop fail2ban
sudo ufw disable
sudo iptables -F
exit"

# -----------------------------------------------------------------------------
# Mitch Marcus — FTP + Docker lab directory access
# Story: IT admin who knows the lab infrastructure; FTP session + docker check
# -----------------------------------------------------------------------------
write_history mitchmarcus "ls
cd Downloads
ls
ftp 172.16.0.2
ls
cd /opt/lab/ftp
docker compose ps
exit"

echo "[scenarios] All bash histories injected."
echo "[scenarios] To reset: re-run this script."