#!/bin/bash
# Pre-Cleanup Verification
# Shows what traces exist before cleanup

echo "=========================================="
echo "  Pre-Cleanup Verification"
echo "=========================================="
echo ""

echo "=== Checking Bash Histories ==="
echo ""

echo "Root bash history:"
if [ -f /root/.bash_history ]; then
    LINES=$(wc -l < /root/.bash_history)
    echo "  Lines: $LINES"
    if [ "$LINES" -gt 0 ]; then
        echo "  ⚠ Contains $LINES lines of history"
        echo "  Sample (last 5 commands):"
        tail -5 /root/.bash_history | sed 's/^/    /'
    fi
else
    echo "  ✓ Does not exist"
fi

echo ""
echo "User bash histories:"
for USER in $(awk -F: '$3 >= 1000 && $3 < 65534 {print $1}' /etc/passwd); do
    USER_HOME=$(eval echo ~$USER)
    if [ -f "$USER_HOME/.bash_history" ]; then
        LINES=$(wc -l < "$USER_HOME/.bash_history")
        echo "  $USER: $LINES lines"
        if [ "$LINES" -gt 50 ] && [ "$USER" != "bob" ] && [ "$USER" != "eve" ]; then
            echo "    ⚠ Unusually large history (may contain setup commands)"
        fi
    else
        echo "  $USER: no history file"
    fi
done

echo ""
echo "=== Checking Logs ==="
echo ""

echo "Auth log size:"
if [ -f /var/log/auth.log ]; then
    SIZE=$(du -h /var/log/auth.log | cut -f1)
    echo "  $SIZE"
    [ "$SIZE" != "0" ] && echo "  ⚠ Contains authentication logs"
else
    echo "  Not found"
fi

echo ""
echo "Syslog size:"
if [ -f /var/log/syslog ]; then
    SIZE=$(du -h /var/log/syslog | cut -f1)
    echo "  $SIZE"
fi

echo ""
echo "Apache logs:"
if [ -d /var/log/apache2 ]; then
    for LOG in access.log error.log; do
        if [ -f "/var/log/apache2/$LOG" ]; then
            SIZE=$(du -h "/var/log/apache2/$LOG" | cut -f1)
            echo "  $LOG: $SIZE"
        fi
    done
fi

echo ""
echo "=== Checking Sessions ==="
echo ""

echo "Tmux sessions:"
TMUX_COUNT=$(tmux list-sessions 2>/dev/null | wc -l)
if [ "$TMUX_COUNT" -gt 0 ]; then
    echo "  ⚠ $TMUX_COUNT active session(s)"
    tmux list-sessions 2>/dev/null | sed 's/^/    /'
else
    echo "  ✓ None"
fi

echo ""
echo "Screen sessions:"
SCREEN_COUNT=$(screen -ls 2>/dev/null | grep -c '\.' || echo 0)
if [ "$SCREEN_COUNT" -gt 0 ]; then
    echo "  ⚠ $SCREEN_COUNT active session(s)"
    screen -ls 2>/dev/null | grep '\.' | sed 's/^/    /'
else
    echo "  ✓ None"
fi

echo ""
echo "=== Checking Temporary Files ==="
echo ""

echo "Files in /tmp:"
TMP_COUNT=$(ls -A /tmp 2>/dev/null | wc -l)
echo "  $TMP_COUNT items"
if [ "$TMP_COUNT" -gt 0 ]; then
    echo "  ⚠ Temporary files exist"
    ls -A /tmp | head -10 | sed 's/^/    /'
    [ "$TMP_COUNT" -gt 10 ] && echo "    ... and $((TMP_COUNT - 10)) more"
fi

echo ""
echo "Files in /var/tmp:"
VARTMP_COUNT=$(ls -A /var/tmp 2>/dev/null | wc -l)
echo "  $VARTMP_COUNT items"

echo ""
echo "=== Checking Setup Scripts ==="
echo ""

echo "Scripts in /root:"
SETUP_SCRIPTS=$(find /root -maxdepth 1 -name "setup-*.sh" -o -name "test-*.sh" -o -name "fix-*.sh" 2>/dev/null | wc -l)
if [ "$SETUP_SCRIPTS" -gt 0 ]; then
    echo "  ⚠ $SETUP_SCRIPTS setup script(s) found"
    find /root -maxdepth 1 \( -name "setup-*.sh" -o -name "test-*.sh" -o -name "fix-*.sh" \) 2>/dev/null | sed 's/^/    /'
else
    echo "  ✓ No setup scripts"
fi

echo ""
echo "=== Checking Swap Files ==="
echo ""

SWAP_COUNT=$(find /home /root /var/www -name ".*.swp" 2>/dev/null | wc -l)
if [ "$SWAP_COUNT" -gt 0 ]; then
    echo "  ⚠ $SWAP_COUNT vim swap file(s)"
    find /home /root /var/www -name ".*.swp" 2>/dev/null | head -5 | sed 's/^/    /'
else
    echo "  ✓ No swap files"
fi

echo ""
echo "=== Checking Backup Files ==="
echo ""

BACKUP_COUNT=$(find /etc /home /root -name "*.bak" 2>/dev/null | wc -l)
if [ "$BACKUP_COUNT" -gt 0 ]; then
    echo "  ⚠ $BACKUP_COUNT backup file(s)"
    find /etc /home /root -name "*.bak" 2>/dev/null | head -5 | sed 's/^/    /'
else
    echo "  ✓ No backup files"
fi

echo ""
echo "=========================================="
echo "  Summary"
echo "=========================================="
echo ""

# Count issues
ISSUES=0

[ "$(wc -l < /root/.bash_history 2>/dev/null || echo 0)" -gt 0 ] && ((ISSUES++))
[ "$TMUX_COUNT" -gt 0 ] && ((ISSUES++))
[ "$SCREEN_COUNT" -gt 0 ] && ((ISSUES++))
[ "$TMP_COUNT" -gt 0 ] && ((ISSUES++))
[ "$SETUP_SCRIPTS" -gt 0 ] && ((ISSUES++))
[ "$SWAP_COUNT" -gt 0 ] && ((ISSUES++))

if [ "$ISSUES" -eq 0 ]; then
    echo "✓ VM appears clean - no obvious traces"
else
    echo "⚠ Found $ISSUES type(s) of traces that should be cleaned"
    echo ""
    echo "Run: ./cleanup-vm.sh"
fi

echo ""
