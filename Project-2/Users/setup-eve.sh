#!/bin/bash
# Eve Account Setup Script
# Creates Eve with SUID Python binary for privilege escalation

echo "=========================================="
echo "  Eve Account Setup"
echo "=========================================="
echo ""

# Check if running as root
if [ "$EUID" -ne 0 ]; then 
    echo "Please run as root (sudo)"
    exit 1
fi

echo "=== Step 1: Create Eve User ==="
echo ""

# Check if eve already exists
if id "eve" &>/dev/null; then
    echo "⚠ User eve already exists"
    read -p "Do you want to reconfigure eve? (y/n) " -n 1 -r
    echo ""
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Skipping eve creation"
    else
        echo "Reconfiguring eve..."
    fi
else
    # Create eve user
    useradd -m -s /bin/bash eve
    echo "✓ User eve created"
fi

# Add eve to devteam group (if it exists, for shared credentials)
if getent group devteam >/dev/null 2>&1; then
    usermod -aG devteam eve
    echo "✓ Eve added to devteam group"
fi

echo ""
echo "=== Step 2: Set Eve's Password ==="
echo ""

# Set password: DevAccess99
echo "eve:DevAccess99" | chpasswd

if [ $? -eq 0 ]; then
    echo "✓ Password set: DevAccess99"
else
    echo "✗ Failed to set password"
    exit 1
fi

echo ""
echo "=== Step 3: Make Eve's Home Directory Readable ==="
echo ""

# Make home directory readable (for credentials in notes)
chmod 755 /home/eve
echo "✓ /home/eve permissions: 755 (readable by others)"

echo ""
echo "=== Step 4: Create Eve's Files (Breadcrumbs) ==="
echo ""

# SSH setup notes with password
cat > /home/eve/ssh_setup_notes.txt << 'EOF'
SSH Key Setup - Legacy Server Access
=====================================

Generated new SSH key for automated deployments
Key location: ~/.ssh/id_rsa

SSH Key Passphrase: DevAccess99
Server Password (fallback): DevAccess99

Deployment Servers:
- legacy.company.local
- inventory.company.local

Legacy Python App:
- Requires SUID binary for hardware sensor access
- Location: /opt/legacy/python3-eve
- DO NOT REMOVE without migration plan!

Setup Date: 2024-11-15
Next Key Rotation: 2025-02-15
EOF

chown eve:eve /home/eve/ssh_setup_notes.txt
chmod 644 /home/eve/ssh_setup_notes.txt

echo "✓ SSH setup notes created"

# Bash history with password hints
cat > /home/eve/.bash_history << 'EOF'
ls -la
cd /opt/legacy
./python3-eve --version
python3 /opt/legacy/inventory_scanner.py
whoami
id
# Testing legacy inventory system
./python3-eve -c "import os; print(os.getuid())"
# Password reminder: DevAccess99
ssh eve@legacy.company.local
cd /home/eve
cat ssh_setup_notes.txt
exit
EOF

chown eve:eve /home/eve/.bash_history
chmod 644 /home/eve/.bash_history

echo "✓ Bash history created"

echo ""
echo "=== Step 5: Create Legacy Directory ==="
echo ""

# Create legacy application directory
mkdir -p /opt/legacy
echo "✓ Directory created: /opt/legacy"

echo ""
echo "=== Step 6: Create SUID Python Binary ==="
echo ""

# Copy system Python to legacy location
cp /usr/bin/python3 /opt/legacy/python3-eve

# Set ownership to root (CRITICAL for privilege escalation)
chown root:root /opt/legacy/python3-eve

# Set SUID bit
chmod u+s /opt/legacy/python3-eve
chmod 755 /opt/legacy/python3-eve

echo "✓ SUID Python binary created: /opt/legacy/python3-eve"

# Verify SUID bit is set
PERMS=$(ls -la /opt/legacy/python3-eve | cut -d' ' -f1)
if echo "$PERMS" | grep -q "rws"; then
    echo "✓ SUID bit verified: $PERMS"
else
    echo "✗ SUID bit NOT set correctly"
    exit 1
fi

echo ""
echo "=== Step 7: Create Legacy Application Files ==="
echo ""

# README explaining the SUID binary
cat > /opt/legacy/README.txt << 'EOF'
Legacy Inventory Management System
===================================

Owner: Eve (Developer)
Created: 2023-08-15
Purpose: Hardware sensor access for inventory tracking

SECURITY NOTE:
--------------
The python3-eve binary has SUID root permissions to allow
direct hardware access to inventory scanners and RFID readers.

This is a TEMPORARY solution until proper privilege separation
is implemented via udev rules and capability-based access control.

MIGRATION PLAN:
- Q1 2024: Design new architecture
- Q2 2024: Implement capability-based system
- Q3 2024: Remove SUID binary

DO NOT REMOVE THIS BINARY WITHOUT CONSULTING EVE FIRST!
Production inventory system depends on it.

Contact: eve@company.local
Ticket: SEC-2847

Testing:
To test the binary works:
  /opt/legacy/python3-eve -c 'import os; print(f"UID: {os.getuid()}, EUID: {os.geteuid()}")'

Privilege escalation (FOR TESTING ONLY):
  /opt/legacy/python3-eve -c 'import os; os.execl("/bin/sh", "sh", "-p")'
EOF

chmod 644 /opt/legacy/README.txt

echo "✓ README.txt created"

# Mock inventory scanner application
cat > /opt/legacy/inventory_scanner.py << 'EOF'
#!/opt/legacy/python3-eve
"""
Legacy Inventory Scanner
Requires SUID Python for hardware access
"""
import os
import sys

def check_permissions():
    """Verify we have necessary permissions"""
    if os.geteuid() != 0:
        print("[ERROR] Insufficient permissions for hardware access")
        print("[INFO] This script requires the SUID python3-eve binary")
        sys.exit(1)
    print("[OK] Hardware access permissions verified")
    print(f"[INFO] Running as UID: {os.getuid()}, EUID: {os.geteuid()}")

def scan_inventory():
    """Mock inventory scanning function"""
    print("[INFO] Initializing RFID scanner...")
    print("[INFO] Scanning inventory items...")
    print("[OK] Scanned 42 items successfully")

if __name__ == "__main__":
    check_permissions()
    scan_inventory()
EOF

chmod 755 /opt/legacy/inventory_scanner.py
chown eve:eve /opt/legacy/inventory_scanner.py

echo "✓ Mock inventory scanner created"

echo ""
echo "=== Step 8: Add Eve's Credentials to Web Config (Discovery Path) ==="
echo ""

# Add Eve's credentials to web application config (if directory exists)
if [ -d /var/www/html/legacy ]; then
    echo "✓ /var/www/html/legacy already exists"
else
    mkdir -p /var/www/html/legacy
    chown www-data:www-data /var/www/html/legacy
    echo "✓ Created /var/www/html/legacy"
fi

cat > /var/www/html/legacy/config.ini << 'EOF'
[application]
name = Inventory Management System
version = 2.1.4
debug = false

[database]
host = localhost
port = 3306
username = inventory_user
password = inv_db_pass_2024

[ssh_access]
# SSH credentials for automated deployment
username = eve
password = DevAccess99
server = localhost

[legacy_system]
python_binary = /opt/legacy/python3-eve
suid_enabled = true
hardware_access = required

[api]
endpoint = https://api.company.local/inventory
api_key = eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
EOF

chown www-data:www-data /var/www/html/legacy/config.ini
chmod 644 /var/www/html/legacy/config.ini

echo "✓ Legacy config created: /var/www/html/legacy/config.ini"

echo ""
echo "=== Step 9: Verification ==="
echo ""

echo "User information:"
id eve

echo ""
echo "Password test:"
echo "DevAccess99" | su eve -c "echo '✓ Password works'" 2>/dev/null || echo "✗ Password test failed"

echo ""
echo "Home directory permissions:"
ls -ld /home/eve
ls -la /home/eve/ssh_setup_notes.txt

echo ""
echo "SUID Python binary:"
ls -la /opt/legacy/python3-eve
file /opt/legacy/python3-eve

echo ""
echo "Test SUID functionality:"
echo "DevAccess99" | su eve -c "/opt/legacy/python3-eve -c 'import os; print(f\"UID: {os.getuid()}, EUID: {os.geteuid()}\")'" 2>/dev/null

echo ""
echo "Web config with credentials:"
if [ -f /var/www/html/legacy/config.ini ]; then
    echo "✓ Config file exists"
    grep "eve" /var/www/html/legacy/config.ini
fi

echo ""
echo "=========================================="
echo "  Eve Setup Complete!"
echo "=========================================="
echo ""
echo "Eve's Credentials:"
echo "  Username: eve"
echo "  Password: DevAccess99"
echo ""
echo "Discovery Paths:"
echo ""
echo "  Path 1 - Web Enumeration:"
echo "    - Find /var/www/html/legacy/config.ini"
echo "    - Contains: username = eve, password = DevAccess99"
echo ""
echo "  Path 2 - Alice/Bob can read Eve's home:"
echo "    - cat /home/eve/ssh_setup_notes.txt"
echo "    - Contains: Password: DevAccess99"
echo ""
echo "  Path 3 - Shared credentials (if devteam group exists):"
echo "    - /opt/devteam/credentials/team_access.txt"
echo ""
echo "Privilege Escalation Path (Eve → Root):"
echo "  1. Find SUID binary during enumeration:"
echo "     find / -perm -4000 -type f 2>/dev/null"
echo ""
echo "  2. Discover: /opt/legacy/python3-eve"
echo ""
echo "  3. Check what it is:"
echo "     file /opt/legacy/python3-eve"
echo "     ls -la /opt/legacy/python3-eve"
echo ""
echo "  4. Read README for context:"
echo "     cat /opt/legacy/README.txt"
echo ""
echo "  5. Exploit (GTFOBins - Python SUID):"
echo "     /opt/legacy/python3-eve -c 'import os; os.execl(\"/bin/sh\", \"sh\", \"-p\")'"
echo ""
echo "  6. Root shell!"
echo "     # whoami"
echo "     root"
echo ""
echo "MITRE ATT&CK Mapping:"
echo "  - T1552.001: Credentials in Files"
echo "  - T1083: File and Directory Discovery"
echo "  - T1548.001: Setuid and Setgid"
echo "  - T1574: Hijack Execution Flow"
echo ""
echo "Teaching Points:"
echo "  - SUID on interpreters is extremely dangerous"
echo "  - Legacy systems as security debt"
echo "  - Credentials in config files"
echo "  - GTFOBins methodology"
echo ""
