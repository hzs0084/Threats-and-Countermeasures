#!/bin/bash
# Bob Account Setup Script
# Creates Bob with password in bash_history (accessible by Alice) and writable cron job

echo "=========================================="
echo "  Bob Account Setup"
echo "=========================================="
echo ""

# Check if running as root
if [ "$EUID" -ne 0 ]; then 
    echo "Please run as root (sudo)"
    exit 1
fi

echo "=== Step 1: Create Bob User ==="
echo ""

# Check if bob already exists
if id "bob" &>/dev/null; then
    echo "⚠ User bob already exists"
    read -p "Do you want to reconfigure bob? (y/n) " -n 1 -r
    echo ""
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Skipping bob creation"
    else
        echo "Reconfiguring bob..."
    fi
else
    # Create bob user
    useradd -m -s /bin/bash bob
    echo "✓ User bob created"
fi

# Add bob to www-data group (for writable cron script)
usermod -aG www-data bob
echo "✓ Bob added to www-data group"

echo ""
echo "=== Step 2: Set Bob's Password ==="
echo ""

# Set password: Ch4L13@123
echo "bob:Ch4L13@123" | chpasswd

if [ $? -eq 0 ]; then
    echo "✓ Password set: Ch4L13@123"
else
    echo "✗ Failed to set password"
    exit 1
fi

echo ""
echo "=== Step 3: Make Bob's Home Directory Readable by Others ==="
echo ""

# VULNERABILITY: Make home directory readable so Alice can access it
chmod 755 /home/bob
echo "✓ /home/bob permissions: 755 (readable by others)"

echo ""
echo "=== Step 4: Create Bob's Bash History with Password ==="
echo ""

# Clear any existing history first
> /home/bob/.bash_history

# Create bash history with password leak
cat > /home/bob/.bash_history << 'EOF'
ls -la
cd /var/www/html
vi /usr/local/bin/bob-backup.sh
chmod +x /usr/local/bin/bob-backup.sh
sudo crontab -e
# Testing MySQL connection for backup script
mysql -u backup_user -p'Ch4L13@123'
# Note to self: change this password next month
echo "Ch4L13@123" | passwd bob --stdin
# Backup script is working great
cd /home/bob
ls
cat backup_notes.txt
exit
EOF

# Set proper ownership but make it READABLE by others (vulnerability)
chown bob:bob /home/bob/.bash_history
chmod 644 /home/bob/.bash_history  # Readable by everyone!

echo "✓ Bash history created with password (readable by others)"

echo ""
echo "=== Step 5: Create Bob's Notes File ==="
echo ""

cat > /home/bob/backup_notes.txt << 'EOF'
Backup System Configuration
============================

Cron Job: Daily at 2 AM
Script: /usr/local/bin/bob-backup.sh
Backup Location: /var/backups/web

Database Credentials (for backup validation):
Username: backup_user
Password: Ch4L13@123

Server Login:
Username: bob
Password: Ch4L13@123

TODO:
- Rotate password next month (security requirement)
- Update backup documentation
- Test restore procedure
- Fix script permissions before next audit
EOF

chown bob:bob /home/bob/backup_notes.txt
chmod 644 /home/bob/backup_notes.txt

echo "✓ Backup notes created"

echo ""
echo "=== Step 6: Create Bob's Backup Script ==="
echo ""

# Create the backup script directory
mkdir -p /usr/local/bin

cat > /usr/local/bin/bob-backup.sh << 'EOF'
#!/bin/bash
# Bob's automated backup script
# Runs daily at 2 AM via root cron

BACKUP_DIR="/var/backups/web"
SOURCE="/var/www/html"

# Create backup directory if it doesn't exist
mkdir -p "$BACKUP_DIR"

# Create backup with timestamp
tar -czf "$BACKUP_DIR/backup-$(date +%Y%m%d-%H%M%S).tar.gz" "$SOURCE" 2>/dev/null

# Clean old backups (keep last 7 days)
find "$BACKUP_DIR" -name "backup-*.tar.gz" -mtime +7 -delete 2>/dev/null

# Log completion
echo "[$(date '+%Y-%m-%d %H:%M:%S')] Backup completed successfully" >> /var/log/bob-backup.log
EOF

# VULNERABILITY: Make script writable by www-data group
chown bob:www-data /usr/local/bin/bob-backup.sh
chmod 775 /usr/local/bin/bob-backup.sh  # Group writable!

echo "✓ Backup script created"
echo "✓ Script ownership: bob:www-data"
echo "✓ Script permissions: 775 (GROUP WRITABLE - vulnerability!)"

echo ""
echo "=== Step 7: Create Backup Directory and Log ==="
echo ""

mkdir -p /var/backups/web
chown root:root /var/backups/web
chmod 755 /var/backups/web

touch /var/log/bob-backup.log
chown root:root /var/log/bob-backup.log
chmod 644 /var/log/bob-backup.log

echo "✓ Backup directory created: /var/backups/web"
echo "✓ Log file created: /var/log/bob-backup.log"

echo ""
echo "=== Step 8: Add Cron Job (runs as root) ==="
echo ""

# Add to root's crontab
CRON_JOB="* * * * * /usr/local/bin/bob-backup.sh"

# Check if already exists
if crontab -l 2>/dev/null | grep -q "bob-backup.sh"; then
    echo "⚠ Cron job already exists"
else
    # Add to crontab
    (crontab -l 2>/dev/null; echo "# Bob's backup script (runs as root)"; echo "$CRON_JOB") | crontab -
    echo "✓ Cron job added to root's crontab"
fi

echo ""
echo "=== Step 9: Verification ==="
echo ""

echo "User information:"
id bob

echo ""
echo "Password test:"
echo "Ch4L13@123" | su bob -c "echo '✓ Password works'" 2>/dev/null || echo "✗ Password test failed"

echo ""
echo "Home directory permissions:"
ls -ld /home/bob
ls -la /home/bob/.bash_history
ls -la /home/bob/backup_notes.txt

echo ""
echo "Backup script permissions:"
ls -la /usr/local/bin/bob-backup.sh

echo ""
echo "Cron job (running as root):"
crontab -l | grep bob-backup

echo ""
echo "Check if Alice can read Bob's files:"
if [ -r /home/bob/.bash_history ]; then
    echo "✓ Alice can read .bash_history"
else
    echo "✗ Alice cannot read .bash_history"
fi

echo ""
echo "Check if www-data can write to backup script:"
if [ -w /usr/local/bin/bob-backup.sh ]; then
    echo "✓ www-data group can write to backup script"
else
    echo "⚠ www-data group cannot write (check group membership)"
fi

echo ""
echo "=========================================="
echo "  Bob Setup Complete!"
echo "=========================================="
echo ""
echo "Bob's Credentials:"
echo "  Username: bob"
echo "  Password: Ch4L13@123"
echo ""
echo "Lateral Movement Path (Alice → Bob):"
echo "  1. As Alice, explore /home directory"
echo "  2. cd /home/bob"
echo "  3. cat .bash_history"
echo "  4. Find password: Ch4L13@123"
echo "  5. su bob (or SSH as bob)"
echo ""
echo "Privilege Escalation Path (Bob → Root):"
echo "  1. As www-data or bob (www-data group member)"
echo "  2. Find writable script: /usr/local/bin/bob-backup.sh"
echo "  3. Check cron: grep -r bob-backup /etc/cron* OR check root crontab"
echo "  4. Inject payload:"
echo "     echo 'cp /bin/bash /tmp/rootbash && chmod +s /tmp/rootbash' >> /usr/local/bin/bob-backup.sh"
echo "  5. Wait for cron (runs every minute)"
echo "  6. Execute: /tmp/rootbash -p"
echo "  7. Root shell!"
echo ""
echo "MITRE ATT&CK Mapping:"
echo "  - T1552.003: Credentials in Files (bash_history)"
echo "  - T1053.003: Scheduled Task/Job (Cron)"
echo "  - T1068: Exploitation for Privilege Escalation"
echo ""
echo "Teaching Points:"
echo "  - Readable bash_history exposes passwords"
echo "  - World-readable home directories"
echo "  - Group-writable scripts run by root"
echo "  - Cron jobs as attack surface"
echo ""
