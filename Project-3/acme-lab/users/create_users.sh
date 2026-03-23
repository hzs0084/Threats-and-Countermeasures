#!/bin/bash
# =============================================================================
# ACME IT Corp - System User Provisioning
# =============================================================================
# Creates all lab user accounts with appropriate groups.
#
# Run independently:  sudo ./users/create_users.sh
# Called by:          setup.sh
#
# What this does NOT do:
#   - Plant bash histories (see scenarios/inject_bash_histories.sh)
#   - Install the backdoor in mallorymartinez's .bashrc (see vulnerabilities/backdoor_bashrc.sh)
#   - Set portal credentials (see config/portal_credentials.txt)
# =============================================================================

set -euo pipefail

echo "[users] Creating ACME IT Corp system accounts..."

# -----------------------------------------------------------------------------
# Helper: create a user if they don't already exist
# -----------------------------------------------------------------------------
create_user() {
    local username="$1"
    if id "$username" &>/dev/null; then
        echo "[users]   $username already exists, skipping"
    else
        useradd -m -s /bin/bash "$username"
        # Set password to username for lab convenience
        echo "$username:$username" | chpasswd
        echo "[users]   Created: $username"
    fi
}

# -----------------------------------------------------------------------------
# IT Admin — sudo + docker access
# -----------------------------------------------------------------------------
create_user mitchmarcus
usermod -aG sudo mitchmarcus
# Add to docker group only if docker is installed
if getent group docker &>/dev/null; then
    usermod -aG docker mitchmarcus
fi

# -----------------------------------------------------------------------------
# Alice Brown — web upload permissions
# Only user explicitly allowed to upload files to the portal
# -----------------------------------------------------------------------------
create_user alicebrown
usermod -aG www-data alicebrown

# -----------------------------------------------------------------------------
# Standard users
# -----------------------------------------------------------------------------
create_user bobbarker
create_user claireredfield
create_user evejohnson

# -----------------------------------------------------------------------------
# Fong Ling — remote access script planted later by vulnerabilities/nodejs_rce.sh
# -----------------------------------------------------------------------------
create_user fongling
mkdir -p /home/fongling/Scripts
mkdir -p /home/fongling/Documents
chown -R fongling:fongling /home/fongling

# -----------------------------------------------------------------------------
# Mallory Martinez — admin, backdoor planted later by vulnerabilities/backdoor_bashrc.sh
# -----------------------------------------------------------------------------
create_user mallorymartinez
usermod -aG sudo mallorymartinez

echo "[users] All accounts provisioned."