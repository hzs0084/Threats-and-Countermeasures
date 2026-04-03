#!/bin/bash

# Configuration
USER="alicebrown"
HOME_DIR="/home/$USER"

echo "[+] Populating environment for $USER (IT Specialist)..."

# 1. Create Directory Structure
mkdir -p $HOME_DIR/{documents,scripts,backups,clients,personal}
mkdir -p $HOME_DIR/documents/SOPs

# 2. Work Related Documents - SOPs and Policies
cat << 'EOF' > $HOME_DIR/documents/SOPs/server_onboarding.md
# ACME IT Corp - Server Onboarding SOP
**Version:** 2.4 (Updated 2024)
**Author:** Alice Brown

1. Provision VM with NAT + Host-Only networking.
2. Ensure SSH is restricted to internal subnet.
3. Install standard defense suite: Snort, Tripwire, Fail2ban.
4. Mallory Martinez must be the only user added to the 'sudo' group.
EOF

cat << 'EOF' > $HOME_DIR/documents/inventory_2025.txt
ACME IT Corp - Hardware Inventory
- Host-01: Primary Web Server (On-premises)
- Host-02: FTP / Storage Server (Admin: Mitch)
- Host-03: Internal Financials (Admin: Claire)
- Network: SOHO Class Gateway
EOF

# 3. Scripts - System Maintenance
cat << 'EOF' > $HOME_DIR/scripts/check_services.sh
#!/bin/bash
# Quick health check for ACME services
services=("apache2" "vsftpd" "snort")

for svc in "${services[@]}"; do
    if systemctl is-active --quiet $svc; then
        echo "[OK] $svc is running"
    else
        echo "[ALERT] $svc is DOWN"
    fi
done
EOF
chmod +x $HOME_DIR/scripts/check_services.sh

# 4. "The Hardened Tell" - Password Manager Note
cat << 'EOF' > $HOME_DIR/documents/reminder.txt
NOTE TO SELF:
The physical backup for the KeePassXC database key is in the secure 
safe in Mallory's office. Do NOT store master passwords in plaintext 
on the server. Mitch keeps getting warned about this.
EOF

# 5. Legacy Breadcrumb (Since she's been here since 2009)
cat << 'EOF' > $HOME_DIR/backups/old_network_map_2012.txt
--- LEGACY DATA - DO NOT DELETE ---
Initial ACME Network Layout:
- Gateway: 192.168.1.1
- FileServer: 192.168.1.10 (Now managed by Mitch)
- DevBox: 192.168.1.15
Note: We transitioned to the NAT+Host-Only structure after the 2010s incident.
EOF

# 6. Personal Touch
cat << 'EOF' > $HOME_DIR/personal/vacation_days.txt
2026 Planned PTO:
- March 20-25: Hiking trip (Approved by Mallory)
- July 12: Work Anniversary (17 years!)
EOF

# Set Ownership and Permissions
chown -R $USER:$USER $HOME_DIR
echo "[+] Alice's environment is now live."
