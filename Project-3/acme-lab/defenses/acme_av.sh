#!/bin/bash
# =============================================================================
# ACME IT Corp - Custom AV / Post-Exploitation Tool Scanner
# =============================================================================
# Deploys the acme-av.sh endpoint protection script and registers it as a
# cron job that runs every minute. The script scans the filesystem for ~25
# named post-exploitation and privilege escalation tools and removes them.
#
# Run independently:  sudo ./defenses/acme_av.sh
# Called by:          setup.sh
#
# AV script location: /usr/local/bin/acme-av.sh
# AV log:             /var/log/acme-av.log
# Cron schedule:      every minute (* * * * *)
#
# ⚠️  CONFLICT: This will delete exploitation tools dropped onto the target
#     during lab exercises within ~60 seconds of placement.
#     Excluded path: /opt/lab/ (tools placed here are NOT removed)
#     To disable temporarily: sudo crontab -r
#     To re-enable:           sudo ./defenses/acme_av.sh
# =============================================================================

set -euo pipefail

echo "[acme_av] Installing ACME endpoint protection script..."

# -----------------------------------------------------------------------------
# Write the AV scanner script
# Scans the entire filesystem (excluding /proc, /sys, /opt/lab) for
# known post-exploitation tool names and removes any matches found
# -----------------------------------------------------------------------------
cat > /usr/local/bin/acme-av.sh << 'EOF'
#!/bin/bash
# ACME IT Corp - Endpoint Protection
# Detects and removes common post-exploitation enumeration and privesc tools
# Runs every minute via cron. Log: /var/log/acme-av.log

LOG="/var/log/acme-av.log"

TOOLS="
linpeas.sh
linpeas
linenum.sh
linux-smart-enumeration.sh
lse.sh
unix-privesc-check
unix-privesc-check.sh
lynis
linfo.sh
enummadeez.sh
linuxprivchecker.py
linux-privchecker.py
tiger
enum4linux
enum4linux.sh
linux-exploit-suggester.sh
linux-exploit-suggester.pl
linux-exploit-suggester-2.pl
les.sh
les2.pl
traitor
sudo_killer.sh
sudo_killer
beroot.py
beroot.sh
uptux.sh
root-seeker.sh
kernel-ascent.sh
privilege-escalator.sh
gtfo-bins-pwnedlist.sh
pwncat
"

for tool in $TOOLS; do
    hits=$(find / -name "$tool" 2>/dev/null \
        | grep -v "^/proc" \
        | grep -v "^/sys" \
        | grep -v "^/opt/lab")   # /opt/lab is excluded — safe zone for lab tools
    if [ -n "$hits" ]; then
        echo "$(date) [ALERT] Detected: $tool" >> "$LOG"
        echo "$hits" >> "$LOG"
        find / -name "$tool" 2>/dev/null \
            | grep -v "^/proc" \
            | grep -v "^/sys" \
            | grep -v "^/opt/lab" \
            | xargs rm -f 2>/dev/null
        echo "$(date) [ACTION] Removed: $tool" >> "$LOG"
    fi
done
EOF

chmod +x /usr/local/bin/acme-av.sh

# -----------------------------------------------------------------------------
# Register cron job (idempotent — removes existing entry first)
# -----------------------------------------------------------------------------
# Remove any existing acme-av cron entry
crontab -l 2>/dev/null | grep -v "acme-av.sh" | crontab - 2>/dev/null || true

# Add the new entry
(crontab -l 2>/dev/null; echo "* * * * * /usr/local/bin/acme-av.sh") | crontab -

echo "[acme_av] Endpoint protection installed."
echo "[acme_av] Cron schedule: every minute"
echo "[acme_av] Excluded path: /opt/lab/ (place lab tools here to avoid removal)"
echo "[acme_av] Alert log: /var/log/acme-av.log"
echo "[acme_av] To disable: sudo crontab -r"
echo "[acme_av] To re-enable: sudo ./defenses/acme_av.sh"

# Verify cron entry
echo "[acme_av] Current crontab:"
crontab -l