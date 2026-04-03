#!/bin/bash

# Ensure script is run as root
if [[ $EUID -ne 0 ]]; then
    echo "This script must be run as root"
    exit 1
fi

# Define users and their core passwords
# Mitch's password is calculated for March 2026 based on the rotation pattern
declare -A users=(
    ["mitchmarcus"]="Adm!n0Sys2019!"
    ["mallorymartinez"]="P3nt3st@Hunt3r!"
    ["alicebrown"]="S3cur!tyIsK3y01"
    ["bobbarker"]="C0mpany0Dir3ctor!"
    ["claireredfield"]="Welcome@Work2019!"
    ["evejohnson"]="T3chL3ad@2020!"
    ["fongling"]="D3v3l0per@Life!"
)

echo "[+] Starting ACME IT Corp User Provisioning..."

for user in "${!users[@]}"; do
    # 1. Create User
    if id "$user" &>/dev/null; then
        echo "[-] User $user already exists, skipping creation..."
    else
        if useradd -m -s /bin/bash "$user"; then
            echo "[+] Created user: $user"
        else
            echo "[!] Failed to create user: $user"
            continue
        fi
    fi

    # 2. Set Password
    echo "$user:${users[$user]}" | chpasswd
    echo "[+] Password set for $user"

    # Optional (good for lab realism): force password change on first login
    # chage -d 0 "$user"

done

# Authorized Root: Add Mallory to sudoers (outside loop)
if id "mallorymartinez" &>/dev/null; then
    usermod -aG sudo mallorymartinez
    echo "[+] Elevated mallorymartinez to sudoers (Authorized Root)"
else
    echo "[!] mallorymartinez does not exist, cannot add to sudo group"
fi

echo "[+] Lab users complete"
