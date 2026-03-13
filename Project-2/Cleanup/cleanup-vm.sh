#!/bin/bash
# Comprehensive Cleanup Script
# Removes all traces of VM setup and configuration

echo "=========================================="
echo "  VM Cleanup - Remove Setup Traces"
echo "=========================================="
echo ""

# Check if running as root
if [ "$EUID" -ne 0 ]; then 
    echo "Please run as root (sudo)"
    exit 1
fi

echo "⚠ WARNING: This will delete bash histories, logs, and temporary files"
echo "This is irreversible!"
echo ""
read -p "Continue with cleanup? (y/n) " -n 1 -r
echo ""
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Cleanup cancelled."
    exit 0
fi

echo ""
echo "=== Step 1: Clear Root Bash History ==="
echo ""

# Clear root's history
cat /dev/null > /root/.bash_history
history -c
history -w

echo "✓ Root bash history cleared"

# Clear root's .bashrc history settings
if [ -f /root/.bashrc ]; then
    echo "✓ Root .bashrc preserved (history settings intact)"
fi

echo ""
echo "=== Step 2: Clear Project1 User History ==="
echo ""

# Find all regular users (UID >= 1000)
USERS=$(awk -F: '$3 >= 1000 && $3 < 65534 {print $1}' /etc/passwd)

for USER in $USERS; do
    USER_HOME=$(eval echo ~$USER)
    
    if [ "$USER" != "alice" ] && [ "$USER" != "bob" ] && [ "$USER" != "eve" ]; then
        # Clear history for non-intentional users (like project1)
        if [ -f "$USER_HOME/.bash_history" ]; then
            cat /dev/null > "$USER_HOME/.bash_history"
            chown $USER:$USER "$USER_HOME/.bash_history"
            echo "✓ Cleared history for: $USER"
        fi
    else
        # Preserve intentional history for alice, bob, eve
        echo "✓ Preserved intentional history for: $USER"
    fi
done

echo ""
echo "=== Step 3: Clear System Logs ==="
echo ""

# Truncate system logs (optional - can make VM look fresh)
read -p "Clear system logs? (y/n) This makes the VM look freshly installed: " -n 1 -r
echo ""
if [[ $REPLY =~ ^[Yy]$ ]]; then
    # Clear auth logs
    > /var/log/auth.log
    > /var/log/auth.log.1
    echo "✓ Cleared auth.log"
    
    # Clear syslog
    > /var/log/syslog
    > /var/log/syslog.1
    echo "✓ Cleared syslog"
    
    # Clear Apache logs (but keep directory structure)
    > /var/log/apache2/access.log
    > /var/log/apache2/error.log
    > /var/log/apache2/other_vhosts_access.log
    echo "✓ Cleared Apache logs"
    
    # Clear other logs
    > /var/log/dpkg.log
    > /var/log/kern.log
    > /var/log/boot.log
    
    # Restart rsyslog to reinitialize
    systemctl restart rsyslog
    echo "✓ All system logs cleared"
else
    echo "✓ System logs preserved"
fi

echo ""
echo "=== Step 4: Clear Package Manager Logs ==="
echo ""

read -p "Clear package installation history? (y/n) Hides what packages you installed: " -n 1 -r
echo ""
if [[ $REPLY =~ ^[Yy]$ ]]; then
    > /var/log/apt/history.log
    > /var/log/apt/term.log
    rm -f /var/log/apt/*.log.*
    echo "✓ APT logs cleared"
else
    echo "✓ APT logs preserved"
fi

echo ""
echo "=== Step 5: Remove Temporary Files ==="
echo ""

# Remove common temp files
rm -rf /tmp/*
rm -rf /var/tmp/*
echo "✓ /tmp and /var/tmp cleared"

# Remove test files in home directories
for USER in alice bob eve; do
    USER_HOME=$(eval echo ~$USER)
    rm -f "$USER_HOME/test"* 2>/dev/null
    rm -f "$USER_HOME/.swp" "$USER_HOME/.*.swp" 2>/dev/null
done
echo "✓ Test files removed from user homes"

# Remove any backup files
find /home -name "*.bak" -delete 2>/dev/null
find /root -name "*.bak" -delete 2>/dev/null
find /etc -name "*.bak" -delete 2>/dev/null
echo "✓ Backup files removed"

echo ""
echo "=== Step 6: Clear Vim/Editor Temporary Files ==="
echo ""

# Remove vim swap files
find /home -name ".*.swp" -delete 2>/dev/null
find /root -name ".*.swp" -delete 2>/dev/null
find /var/www -name ".*.swp" -delete 2>/dev/null

# Remove vim info files
find /home -name ".viminfo" -delete 2>/dev/null
rm -f /root/.viminfo 2>/dev/null

echo "✓ Editor temporary files removed"

echo ""
echo "=== Step 7: Kill and Remove Tmux Sessions ==="
echo ""

# List tmux sessions
TMUX_SESSIONS=$(tmux list-sessions 2>/dev/null | cut -d: -f1)

if [ -n "$TMUX_SESSIONS" ]; then
    echo "Found tmux sessions:"
    tmux list-sessions
    echo ""
    
    for SESSION in $TMUX_SESSIONS; do
        tmux kill-session -t "$SESSION" 2>/dev/null
        echo "✓ Killed tmux session: $SESSION"
    done
else
    echo "✓ No tmux sessions found"
fi

# Remove tmux temporary files
rm -rf /tmp/tmux-* 2>/dev/null
echo "✓ Tmux temporary files removed"

echo ""
echo "=== Step 8: Clear Screen Sessions ==="
echo ""

# Kill all screen sessions
SCREEN_SESSIONS=$(screen -ls 2>/dev/null | grep -oP '\d+\.\S+' || true)

if [ -n "$SCREEN_SESSIONS" ]; then
    for SESSION in $SCREEN_SESSIONS; do
        screen -S "$SESSION" -X quit 2>/dev/null
        echo "✓ Killed screen session: $SESSION"
    done
else
    echo "✓ No screen sessions found"
fi

echo ""
echo "=== Step 9: Clear SSH Known Hosts ==="
echo ""

# Clear SSH known hosts for all users
for USER in root $USERS; do
    USER_HOME=$(eval echo ~$USER)
    if [ -f "$USER_HOME/.ssh/known_hosts" ]; then
        > "$USER_HOME/.ssh/known_hosts"
        echo "✓ Cleared SSH known_hosts for: $USER"
    fi
done

echo ""
echo "=== Step 10: Clear Less History ==="
echo ""

# Remove less history files
find /home -name ".lesshst" -delete 2>/dev/null
rm -f /root/.lesshst 2>/dev/null
echo "✓ Less history files removed"

echo ""
echo "=== Step 11: Clear MySQL/Database History ==="
echo ""

# Remove MySQL history
find /home -name ".mysql_history" -delete 2>/dev/null
rm -f /root/.mysql_history 2>/dev/null
echo "✓ MySQL history files removed"

echo ""
echo "=== Step 12: Clear Python History ==="
echo ""

# Remove Python history
find /home -name ".python_history" -delete 2>/dev/null
rm -f /root/.python_history 2>/dev/null
echo "✓ Python history files removed"

echo ""
echo "=== Step 13: Remove Setup Scripts ==="
echo ""

read -p "Remove setup scripts from /root and /home? (y/n): " -n 1 -r
echo ""
if [[ $REPLY =~ ^[Yy]$ ]]; then
    rm -f /root/setup-*.sh 2>/dev/null
    rm -f /root/test-*.sh 2>/dev/null
    rm -f /root/fix-*.sh 2>/dev/null
    rm -f /root/verify-*.sh 2>/dev/null
    rm -f /root/check-*.sh 2>/dev/null
    rm -f /root/*.md 2>/dev/null
    rm -f /root/*.txt 2>/dev/null
    
    # Also check Downloads if exists
    rm -f /root/Downloads/setup-*.sh 2>/dev/null
    rm -f /root/Downloads/*.sh 2>/dev/null
    
    echo "✓ Setup scripts removed from /root"
else
    echo "✓ Setup scripts preserved"
fi

echo ""
echo "=== Step 14: Clear Journal Logs (systemd) ==="
echo ""

read -p "Clear systemd journal logs? (y/n) Removes system service logs: " -n 1 -r
echo ""
if [[ $REPLY =~ ^[Yy]$ ]]; then
    journalctl --vacuum-time=1s 2>/dev/null
    echo "✓ Journal logs cleared"
else
    echo "✓ Journal logs preserved"
fi

echo ""
echo "=== Step 15: Clear Samba Logs ==="
echo ""

if [ -d /var/log/samba ]; then
    > /var/log/samba/log.smbd 2>/dev/null
    > /var/log/samba/log.nmbd 2>/dev/null
    echo "✓ Samba logs cleared"
fi

echo ""
echo "=== Step 16: Clear Cron Logs ==="
echo ""

> /var/log/cron.log 2>/dev/null
echo "✓ Cron logs cleared"

echo ""
echo "=== Step 17: Clear Web Application Logs ==="
echo ""

if [ -f /var/www/html/data/uploads.txt ]; then
    > /var/www/html/data/uploads.txt
    echo "✓ Upload log cleared"
fi

echo ""
echo "=== Step 18: Remove Recently Used Files ==="
echo ""

# Remove recently used file lists
find /home -name "recently-used.xbel" -delete 2>/dev/null
find /home -name ".recently-used" -delete 2>/dev/null
echo "✓ Recently used files removed"

echo ""
echo "=== Step 19: Clear Command History (Current Session) ==="
echo ""

# Clear current session history
history -c
history -w

# Remove history file
unset HISTFILE

echo "✓ Current session history cleared"

echo ""
echo "=== Step 20: Final Verification ==="
echo ""

echo "Checking what's left..."
echo ""

echo "Root bash history size:"
wc -l /root/.bash_history 2>/dev/null || echo "  Empty or missing"

echo ""
echo "User bash histories:"
for USER in $(awk -F: '$3 >= 1000 && $3 < 65534 {print $1}' /etc/passwd); do
    USER_HOME=$(eval echo ~$USER)
    if [ -f "$USER_HOME/.bash_history" ]; then
        LINES=$(wc -l < "$USER_HOME/.bash_history")
        if [ "$LINES" -gt 0 ]; then
            echo "  $USER: $LINES lines"
        else
            echo "  $USER: empty"
        fi
    fi
done

echo ""
echo "Active tmux sessions:"
tmux list-sessions 2>/dev/null || echo "  None"

echo ""
echo "Active screen sessions:"
screen -ls 2>/dev/null | grep -v "No Sockets" || echo "  None"

echo ""
echo "=========================================="
echo "  Cleanup Complete!"
echo "=========================================="
echo ""
echo "Summary of what was cleaned:"
echo ""
echo "✓ Root bash history"
echo "✓ Project1 user history (non-alice/bob/eve)"
echo "✓ System logs (if selected)"
echo "✓ Package manager logs (if selected)"
echo "✓ Temporary files (/tmp, /var/tmp)"
echo "✓ Editor swap files (.swp, .viminfo)"
echo "✓ Tmux sessions"
echo "✓ Screen sessions"
echo "✓ SSH known_hosts"
echo "✓ Less/MySQL/Python histories"
echo "✓ Setup scripts (if selected)"
echo "✓ Journal logs (if selected)"
echo ""
echo "Preserved (intentional for students):"
echo "✓ Alice's bash history (empty/clean)"
echo "✓ Bob's bash history (contains password)"
echo "✓ Eve's bash history (contains hints)"
echo "✓ SMB share and credentials"
echo "✓ User accounts and configurations"
echo "✓ Privilege escalation vectors"
echo ""
echo "IMPORTANT: Log out and back in to clear current session!"
echo ""
