#!/bin/bash
# =============================================================================
# ACME IT Corp - Snort NIDS Setup
# =============================================================================
# Installs and configures Snort 2 with a custom ACME ruleset covering:
#   - nmap scan detection (SYN, NULL, XMAS, FIN)
#   - Ping sweep detection
#   - FTP login and vsftpd backdoor detection
#   - Directory enumeration tool detection (gobuster, dirbuster, nikto)
#   - PHP webshell cmd= parameter detection
#   - Outbound reverse shell detection (/bin/sh)
#   - SSH brute force detection
#
# Monitors interface: enp0s8 (192.168.56.0/24)
# Alert log:          /var/log/snort/snort.alert.fast
#
# Run independently:  sudo ./defenses/snort.sh
# Called by:          setup.sh
#
# ⚠️  CONFLICT: Many lab exercises will intentionally trigger Snort alerts.
#     See defenses/README.md for the full conflict map.
#     To watch alerts live: sudo tail -f /var/log/snort/snort.alert.fast
# =============================================================================

set -euo pipefail

echo "[snort] Installing Snort..."

apt install -y snort

# -----------------------------------------------------------------------------
# Configure HOME_NET and interface
# Targets the host-only adapter (enp0s8) on 192.168.56.0/24
# -----------------------------------------------------------------------------
sed -i 's/ipvar HOME_NET any/ipvar HOME_NET 192.168.56.0\/24/' \
    /etc/snort/snort.conf

sed -i 's/DEBIAN_SNORT_HOME_NET="192.168.0.0\/16"/DEBIAN_SNORT_HOME_NET="192.168.56.0\/24"/' \
    /etc/snort/snort.debian.conf

sed -i 's/DEBIAN_SNORT_INTERFACE="enp0s3"/DEBIAN_SNORT_INTERFACE="enp0s8"/' \
    /etc/snort/snort.debian.conf

# -----------------------------------------------------------------------------
# Enable local.rules include in snort.conf
# -----------------------------------------------------------------------------
sed -i 's|# include \$RULE_PATH/local.rules|include $RULE_PATH/local.rules|' \
    /etc/snort/snort.conf

# -----------------------------------------------------------------------------
# Write ACME custom rules
# -----------------------------------------------------------------------------
cat > /etc/snort/rules/local.rules << 'EOF'
# =============================================================================
# ACME IT Corp - Snort Local Rules
# =============================================================================

# --- Reconnaissance ---

# Detect nmap SYN scan (5 SYN packets in 2 seconds)
alert tcp any any -> $HOME_NET any (msg:"NMAP SYN Scan Detected"; flags:S; threshold:type threshold, track by_src, count 5, seconds 2; sid:1000001; rev:1;)

# Detect nmap NULL scan (no flags)
alert tcp any any -> $HOME_NET any (msg:"NMAP NULL Scan Detected"; flags:0; sid:1000002; rev:1;)

# Detect nmap XMAS scan (FIN+PSH+URG)
alert tcp any any -> $HOME_NET any (msg:"NMAP XMAS Scan Detected"; flags:FPU; sid:1000003; rev:1;)

# Detect nmap FIN scan
alert tcp any any -> $HOME_NET any (msg:"NMAP FIN Scan Detected"; flags:F; sid:1000004; rev:1;)

# Detect ICMP ping sweep (5 pings in 2 seconds)
alert icmp any any -> $HOME_NET any (msg:"ICMP Ping Sweep Detected"; threshold:type threshold, track by_src, count 5, seconds 2; sid:1000005; rev:1;)

# --- FTP / vsftpd ---

# Detect FTP login attempts
alert tcp any any -> $HOME_NET 21 (msg:"FTP Login Attempt"; content:"USER"; nocase; sid:1000006; rev:1;)

# Detect vsftpd 2.3.4 backdoor trigger (username ending in ":)")
alert tcp any any -> $HOME_NET 21 (msg:"VSFTPD Backdoor Attempt - Smiley Trigger"; content:":)"; sid:1000007; rev:1;)

# Detect connection to vsftpd backdoor shell on port 6200
alert tcp any any -> $HOME_NET 6200 (msg:"VSFTPD Backdoor Shell Connection on Port 6200"; sid:1000008; rev:1;)

# --- Web Enumeration ---

# Detect gobuster User-Agent
alert tcp any any -> $HOME_NET 80 (msg:"Directory Enumeration Tool Detected - gobuster"; content:"gobuster"; nocase; http_header; sid:1000009; rev:1;)

# Detect DirBuster User-Agent
alert tcp any any -> $HOME_NET 80 (msg:"Directory Enumeration Tool Detected - DirBuster"; content:"DirBuster"; nocase; http_header; sid:1000010; rev:1;)

# --- Webshell ---

# Detect PHP webshell cmd= parameter in HTTP requests
alert tcp any any -> $HOME_NET 80 (msg:"PHP Webshell cmd Parameter Detected"; content:"cmd="; nocase; sid:1000011; rev:1;)

# --- Reverse Shell ---

# Detect outbound /bin/sh (reverse shell indicator)
alert tcp $HOME_NET any -> any any (msg:"Possible Reverse Shell Outbound"; content:"/bin/sh"; sid:1000012; rev:1;)

# --- Brute Force ---

# Detect SSH brute force (5 attempts in 60 seconds from same source)
alert tcp any any -> $HOME_NET 22 (msg:"SSH Brute Force Attempt"; threshold:type threshold, track by_src, count 5, seconds 60; sid:1000013; rev:1;)

# --- Scanners ---

# Detect Nikto scanner User-Agent
alert tcp any any -> $HOME_NET 80 (msg:"Nikto Scanner Detected"; content:"Nikto"; nocase; http_header; sid:1000014; rev:1;)
EOF

# -----------------------------------------------------------------------------
# Create snort user and log directory
# -----------------------------------------------------------------------------
useradd -r -s /usr/sbin/nologin snort 2>/dev/null || true
mkdir -p /var/log/snort
chown -R snort:snort /var/log/snort
chmod 750 /var/log/snort

# -----------------------------------------------------------------------------
# Systemd service definition
# Runs as snort user, quiet mode, logs to /var/log/snort
# -----------------------------------------------------------------------------
cat > /etc/systemd/system/snort.service << 'EOF'
[Unit]
Description=Snort NIDS
After=network.target

[Service]
Type=simple
ExecStart=/usr/sbin/snort -q -u snort -g snort -c /etc/snort/snort.conf -i enp0s8 -l /var/log/snort
ExecReload=/bin/kill -HUP $MAINPID
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable snort
systemctl start snort

# -----------------------------------------------------------------------------
# Validate config
# -----------------------------------------------------------------------------
echo "[snort] Validating configuration..."
snort -T -i enp0s8 -c /etc/snort/snort.conf 2>&1 | tail -3

echo "[snort] Snort NIDS running on enp0s8."
echo "[snort] Alert log: /var/log/snort/snort.alert.fast"
echo "[snort] Watch live: sudo tail -f /var/log/snort/snort.alert.fast"