#!/bin/bash
# SMB Verification Script
# Tests that SMB is working correctly

echo "=========================================="
echo "  SMB Verification Tests"
echo "=========================================="
echo ""

echo "=== Test 1: Check Services Running ==="
echo ""

if systemctl is-active --quiet smbd; then
    echo "✓ smbd is running"
else
    echo "✗ smbd is NOT running"
    echo "  Fix: sudo systemctl start smbd"
fi

if systemctl is-active --quiet nmbd; then
    echo "✓ nmbd is running"
else
    echo "✗ nmbd is NOT running"
    echo "  Fix: sudo systemctl start nmbd"
fi

echo ""
echo "=== Test 2: Check Ports Listening ==="
echo ""

if netstat -tulnp 2>/dev/null | grep -q ":139 " || ss -tulnp 2>/dev/null | grep -q ":139 "; then
    echo "✓ Port 139 (NetBIOS) is listening"
else
    echo "✗ Port 139 is NOT listening"
fi

if netstat -tulnp 2>/dev/null | grep -q ":445 " || ss -tulnp 2>/dev/null | grep -q ":445 "; then
    echo "✓ Port 445 (SMB) is listening"
else
    echo "✗ Port 445 is NOT listening"
fi

echo ""
echo "=== Test 3: Check Share Directory ==="
echo ""

if [ -d /srv/samba/public ]; then
    echo "✓ Share directory exists"
    ls -ld /srv/samba/public
else
    echo "✗ Share directory missing"
fi

if [ -f /srv/samba/public/alice_files/temp_access.txt ]; then
    echo "✓ Alice's credential file exists"
else
    echo "✗ Alice's credential file missing"
fi

echo ""
echo "=== Test 4: Check Permissions ==="
echo ""

OWNER=$(stat -c '%U:%G' /srv/samba/public 2>/dev/null)
if [ "$OWNER" = "nobody:nogroup" ]; then
    echo "✓ Directory ownership correct: nobody:nogroup"
else
    echo "✗ Directory ownership incorrect: $OWNER"
    echo "  Should be: nobody:nogroup"
fi

PERMS=$(stat -c '%a' /srv/samba/public 2>/dev/null)
if [ "$PERMS" = "755" ]; then
    echo "✓ Directory permissions correct: 755"
else
    echo "⚠ Directory permissions: $PERMS (expected 755)"
fi

echo ""
echo "=== Test 5: Test Anonymous Connection (Local) ==="
echo ""

smbclient -L //localhost -N 2>&1 | grep -q "Public" && echo "✓ Can list shares anonymously" || echo "✗ Cannot list shares"

echo ""
echo "=== Test 6: Test File Retrieval ==="
echo ""

TMP_DIR=$(mktemp -d)
cd "$TMP_DIR"

smbclient //localhost/Public -N -c "cd alice_files; get temp_access.txt" 2>&1 | grep -q "getting file" && echo "✓ Can retrieve files" || echo "✗ Cannot retrieve files"

if [ -f temp_access.txt ]; then
    if grep -q "alice" temp_access.txt && grep -q "TempAccess2026" temp_access.txt; then
        echo "✓ Credentials file contains correct information"
    else
        echo "⚠ Credentials file content incorrect"
    fi
    rm -f temp_access.txt
fi

cd - > /dev/null
rm -rf "$TMP_DIR"

echo ""
echo "=== Test 7: Samba Configuration ==="
echo ""

testparm -s 2>&1 | grep -q "Public" && echo "✓ Public share configured" || echo "✗ Public share not found in config"

echo ""
echo "=========================================="
echo "  Test Summary"
echo "=========================================="
echo ""

echo "From attacking machine (Kali), students should run:"
echo ""
echo "# Nmap scan"
echo "nmap -p 139,445 192.168.56.21"
echo ""
echo "# List shares"
echo "smbclient -L //192.168.56.21 -N"
echo ""
echo "# Connect to share"
echo "smbclient //192.168.56.21/Public -N"
echo ""
echo "# Browse and download"
echo "smb: \\> ls"
echo "smb: \\> cd alice_files"
echo "smb: \\> get temp_access.txt"
echo "smb: \\> exit"
echo ""
echo "# Read credentials"
echo "cat temp_access.txt"
echo ""
echo "# Use enum4linux"
echo "enum4linux -a 192.168.56.21"
echo ""
