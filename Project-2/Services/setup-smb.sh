#!/bin/bash
# SMB Setup Script - ARM VM
# Creates anonymous SMB share with Alice's credentials

echo "=========================================="
echo "  SMB Anonymous Share Setup"
echo "=========================================="
echo ""

# Check if running as root
if [ "$EUID" -ne 0 ]; then 
    echo "Please run as root (sudo)"
    exit 1
fi

echo "=== Step 1: Install Samba ==="
echo ""

apt-get update
apt-get install -y samba samba-common-bin

if [ $? -eq 0 ]; then
    echo "✓ Samba installed"
else
    echo "✗ Failed to install Samba"
    exit 1
fi

echo ""
echo "=== Step 2: Create Share Directory ==="
echo ""

# Create directory structure
mkdir -p /srv/samba/public/alice_files
chmod 755 /srv/samba/public
chmod 755 /srv/samba/public/alice_files

echo "✓ Directories created"

echo ""
echo "=== Step 3: Create Alice's Credential Files ==="
echo ""

# File 1: Temporary access credentials
cat > /srv/samba/public/alice_files/temp_access.txt << 'EOF'
Temporary Admin Access - Q4 Security Audit
===========================================

User: alice
Password: TempAccess2026
Access Level: sudo /usr/bin/less
Duration: Until quarterly review completion

Note: Remember to revoke after audit!
EOF

# File 2: Web admin backup config (alternative discovery)
cat > /srv/samba/public/alice_files/web_admin_backup.conf << 'EOF'
# Web Admin Configuration Backup
# Date: 2024-11-15

[admin_users]
mallory = AdminPortal2026
alice = TempAccess2026  # Temporary - Q4 audit access

[access_levels]
mallory = full
alice = logs_only
EOF

chmod 644 /srv/samba/public/alice_files/*
echo "✓ Credential files created"

echo ""
echo "=== Step 4: Create Additional Breadcrumb Files ==="
echo ""

# Meeting notes
cat > /srv/samba/public/IT_MEETING_NOTES.txt << 'EOF'
IT Team Meeting - November 2024
================================

- Set up public SMB share for file transfers
- Alice granted temporary sudo for Q4 audit
- Bob's backup script running smoothly
- TODO: Review Eve's legacy Python app security

Next meeting: December 15th
EOF

# Old passwords file (contains real credentials mixed with old ones)
cat > /srv/samba/public/old_passwords_DO_NOT_USE.txt << 'EOF'
# Deprecated passwords - migrated to new system
# DO NOT USE THESE

admin:OldP@ss2023
webmaster:Test123!
alice:TempAccess2026
helpdesk:Welcome1

# New password policy enforced Jan 2024
EOF

chmod 644 /srv/samba/public/*.txt
echo "✓ Breadcrumb files created"

echo ""
echo "=== Step 5: Set Ownership ==="
echo ""

# Set ownership to nobody:nogroup for anonymous access
chown -R nobody:nogroup /srv/samba/public
echo "✓ Ownership set to nobody:nogroup"

echo ""
echo "=== Step 6: Backup Original Samba Config ==="
echo ""

cp /etc/samba/smb.conf /etc/samba/smb.conf.bak
echo "✓ Backup created: /etc/samba/smb.conf.bak"

echo ""
echo "=== Step 7: Configure Samba ==="
echo ""

# Create new Samba configuration
cat > /etc/samba/smb.conf << 'EOF'
[global]
   workgroup = WORKGROUP
   server string = Company File Server
   security = user
   map to guest = Bad User
   guest account = nobody
   
   # Disable printing services (cleaner for lab)
   load printers = no
   printing = bsd
   printcap name = /dev/null
   disable spoolss = yes
   
   # Logging
   log file = /var/log/samba/log.%m
   max log size = 50

[Public]
   comment = Public Company Files
   path = /srv/samba/public
   browsable = yes
   writable = no
   guest ok = yes
   read only = yes
   create mask = 0644
   directory mask = 0755
   force user = nobody
   force group = nogroup
EOF

echo "✓ Samba configuration written"

echo ""
echo "=== Step 8: Test Samba Configuration ==="
echo ""

testparm -s

if [ $? -eq 0 ]; then
    echo ""
    echo "✓ Samba configuration is valid"
else
    echo ""
    echo "✗ Samba configuration has errors!"
    echo "Restoring backup..."
    cp /etc/samba/smb.conf.bak /etc/samba/smb.conf
    exit 1
fi

echo ""
echo "=== Step 9: Restart Samba Services ==="
echo ""

systemctl restart smbd
systemctl restart nmbd

# Enable on boot
systemctl enable smbd
systemctl enable nmbd

echo "✓ Samba services restarted and enabled"

echo ""
echo "=== Step 10: Configure Firewall (if enabled) ==="
echo ""

if systemctl is-active --quiet ufw; then
    echo "UFW is active, adding Samba rules..."
    ufw allow samba
    ufw allow 139/tcp
    ufw allow 445/tcp
    echo "✓ Firewall rules added"
else
    echo "UFW is not active, skipping firewall configuration"
fi

echo ""
echo "=== Step 11: Verification ==="
echo ""

echo "Checking Samba services:"
systemctl status smbd --no-pager | grep -E "(Active|Loaded)"
systemctl status nmbd --no-pager | grep -E "(Active|Loaded)"

echo ""
echo "Checking listening ports:"
netstat -tulnp | grep -E "139|445" || ss -tulnp | grep -E "139|445"

echo ""
echo "Testing local connection:"
smbclient -L //localhost -N

echo ""
echo "=========================================="
echo "  SMB Setup Complete!"
echo "=========================================="
echo ""
echo "Students can discover credentials via:"
echo ""
echo "1. List shares:"
echo "   smbclient -L //192.168.56.21 -N"
echo ""
echo "2. Connect to share:"
echo "   smbclient //192.168.56.21/Public -N"
echo ""
echo "3. Browse files:"
echo "   smb: \\> ls"
echo "   smb: \\> cd alice_files"
echo "   smb: \\> get temp_access.txt"
echo ""
echo "4. Or use enum4linux:"
echo "   enum4linux -a 192.168.56.21"
echo ""
echo "Files containing alice credentials:"
echo "  - /srv/samba/public/alice_files/temp_access.txt"
echo "  - /srv/samba/public/alice_files/web_admin_backup.conf"
echo "  - /srv/samba/public/old_passwords_DO_NOT_USE.txt"
echo ""
echo "Alice's credentials: alice:TempAccess2026"
echo ""
