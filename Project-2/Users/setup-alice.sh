#!/bin/bash
# Alice Account Setup Script
# Creates Alice with password and sudo privileges for privilege escalation

echo "=========================================="
echo "  Alice Account Setup"
echo "=========================================="
echo ""

# Check if running as root
if [ "$EUID" -ne 0 ]; then 
    echo "Please run as root (sudo)"
    exit 1
fi

echo "=== Step 1: Create Alice User ==="
echo ""

# Check if alice already exists
if id "alice" &>/dev/null; then
    echo "⚠ User alice already exists"
    read -p "Do you want to reconfigure alice? (y/n) " -n 1 -r
    echo ""
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Skipping alice creation"
    else
        echo "Reconfiguring alice..."
    fi
else
    # Create alice user
    useradd -m -s /bin/bash alice
    echo "✓ User alice created"
fi

echo ""
echo "=== Step 2: Set Alice's Password ==="
echo ""

# Set password: TempAccess2026
echo "alice:TempAccess2026" | chpasswd

if [ $? -eq 0 ]; then
    echo "✓ Password set: TempAccess2026"
else
    echo "✗ Failed to set password"
    exit 1
fi

echo ""
echo "=== Step 3: Configure Sudo Access ==="
echo ""

# Add alice to sudoers with NOPASSWD for /usr/bin/less
# This is the privilege escalation vulnerability

# Check if already configured
if sudo -l -U alice 2>/dev/null | grep -q "less"; then
    echo "⚠ Alice sudo access already configured"
else
    echo "Adding sudo configuration..."
    
    # Add to sudoers
    cat >> /etc/sudoers.d/alice << 'EOF'
# Alice - temporary log review access for Q4 audit
# VULNERABILITY: less can spawn shells
alice ALL=(ALL) NOPASSWD: /usr/bin/less
EOF
    
    # Set proper permissions on sudoers file
    chmod 440 /etc/sudoers.d/alice
    
    # Verify syntax
    visudo -c -f /etc/sudoers.d/alice
    
    if [ $? -eq 0 ]; then
        echo "✓ Sudo configuration added"
    else
        echo "✗ Sudo configuration has errors"
        rm /etc/sudoers.d/alice
        exit 1
    fi
fi

echo ""
echo "=== Step 4: Create Alice's Home Directory Content ==="
echo ""

# Create a notes file in Alice's home (breadcrumb/realism)
cat > /home/alice/.bash_history << 'EOF'
ls -la
cd /var/www/html
sudo less /var/log/apache2/access.log
pwd
whoami
exit
EOF

chown alice:alice /home/alice/.bash_history
chmod 600 /home/alice/.bash_history

echo "✓ Bash history created"

# Create a notes file
cat > /home/alice/AUDIT_NOTES.txt << 'EOF'
Q4 Security Audit - Alice's Notes
==================================

Tasks:
- Review web server logs (use: sudo less /var/log/apache2/access.log)
- Check for suspicious uploads
- Verify user access controls
- Document findings

Sudo Access:
- Granted temporary access to 'less' command for log review
- Access level: NOPASSWD for /usr/bin/less
- Duration: Until audit completion

Next Steps:
- Complete log analysis
- Submit report to management
- Access to be revoked after quarterly review
EOF

chown alice:alice /home/alice/AUDIT_NOTES.txt
chmod 644 /home/alice/AUDIT_NOTES.txt

echo "✓ Audit notes created"

# Set proper permissions on home directory
chmod 755 /home/alice

echo "✓ Home directory configured"

echo ""
echo "=== Step 5: Verification ==="
echo ""

echo "User information:"
id alice

echo ""
echo "Password test:"
echo "TempAccess2026" | su alice -c "echo '✓ Password works'" 2>/dev/null || echo "✗ Password test failed"

echo ""
echo "Sudo privileges:"
sudo -l -U alice

echo ""
echo "Home directory:"
ls -la /home/alice/

echo ""
echo "=========================================="
echo "  Alice Setup Complete!"
echo "=========================================="
echo ""
echo "Alice's Credentials:"
echo "  Username: alice"
echo "  Password: TempAccess2026"
echo ""
echo "Privilege Escalation Path:"
echo "  1. SSH as alice"
echo "  2. Run: sudo -l"
echo "  3. See: (ALL) NOPASSWD: /usr/bin/less"
echo "  4. Exploit: sudo less /etc/passwd"
echo "  5. Inside less, type: !/bin/sh"
echo "  6. Get root shell!"
echo ""
echo "GTFOBins reference:"
echo "  https://gtfobins.github.io/gtfobins/less/"
echo ""
echo "Teaching Points:"
echo "  - NOPASSWD sudo without restrictions"
echo "  - Pagers can spawn shells"
echo "  - Temporary access becomes permanent"
echo "  - Least privilege principle violation"
echo ""
