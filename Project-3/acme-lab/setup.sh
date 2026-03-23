#!/bin/bash
# =============================================================================
# ACME IT Corp - Lab Master Setup Script
# =============================================================================
# Builds the full ACME cybersecurity lab environment in the correct order.
# Vulnerabilities are deployed by default.
#
# Usage:
#   sudo ./setup.sh              # Full lab with vulnerabilities (default)
#   sudo ./setup.sh --no-vulns  # Services and defenses only, no vulns
#   sudo ./setup.sh --help       # Show this help
#
# Requirements:
#   - Ubuntu 22.04 LTS
#   - Two NICs: enp0s3 (DHCP/NAT) and enp0s8 (static 192.168.56.21/24)
#   - sudo privileges
#   - Internet access (for apt installs)
#
# See README.md for full prerequisites and sequencing warnings.
# =============================================================================

set -euo pipefail

# -----------------------------------------------------------------------------
# Argument parsing
# -----------------------------------------------------------------------------
DEPLOY_VULNS=true

for arg in "$@"; do
    case "$arg" in
        --no-vulns)
            DEPLOY_VULNS=false
            ;;
        --help|-h)
            head -20 "$0" | grep "^#" | sed 's/^# \?//'
            exit 0
            ;;
        *)
            echo "Unknown argument: $arg"
            echo "Usage: sudo ./setup.sh [--no-vulns] [--help]"
            exit 1
            ;;
    esac
done

# -----------------------------------------------------------------------------
# Root check
# -----------------------------------------------------------------------------
if [[ "$EUID" -ne 0 ]]; then
    echo "ERROR: This script must be run as root."
    echo "Usage: sudo ./setup.sh"
    exit 1
fi

# -----------------------------------------------------------------------------
# Resolve script directory so modules can be called with relative paths
# regardless of where setup.sh is invoked from
# -----------------------------------------------------------------------------
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

run_module() {
    local script="$1"
    local label="$2"
    echo ""
    echo "========================================================"
    echo "  $label"
    echo "========================================================"
    bash "${SCRIPT_DIR}/${script}"
}

# -----------------------------------------------------------------------------
# Summary
# -----------------------------------------------------------------------------
echo ""
echo "========================================================"
echo "  ACME IT Corp - Lab Setup"
echo "  Deploy vulnerabilities: $DEPLOY_VULNS"
echo "========================================================"
echo ""

# -----------------------------------------------------------------------------
# System update
# -----------------------------------------------------------------------------
echo "[setup] Updating system packages..."
apt update -q
apt upgrade -y -q

# -----------------------------------------------------------------------------
# Install base dependencies
# -----------------------------------------------------------------------------
echo "[setup] Installing base packages..."
apt install -y \
    curl wget git unzip vim \
    net-tools \
    openssl \
    build-essential \
    libpcre3-dev libdumbnet-dev libpcap-dev zlib1g-dev \
    ca-certificates gnupg lsb-release \
    cron \
    auditd

# -----------------------------------------------------------------------------
# Docker installation
# (required by services/vsftpd.sh)
# -----------------------------------------------------------------------------
echo "[setup] Installing Docker..."
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | \
    gpg --dearmor -o /etc/apt/keyrings/docker.gpg
chmod a+r /etc/apt/keyrings/docker.gpg

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
  https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | \
  tee /etc/apt/sources.list.d/docker.list > /dev/null

apt update -q
apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

systemctl enable docker
systemctl start docker

# -----------------------------------------------------------------------------
# MODULE: Users
# -----------------------------------------------------------------------------
run_module "users/create_users.sh" "Users"

# -----------------------------------------------------------------------------
# MODULE: Services
# Order: ssh → apache → vsftpd (needs docker) → dashboard (needs node)
# -----------------------------------------------------------------------------
run_module "services/ssh.sh"       "Service: SSH"
run_module "services/apache.sh"    "Service: Apache + PHP"
run_module "services/vsftpd.sh"    "Service: vsftpd (backdoor version)"
run_module "services/dashboard.sh" "Service: Next.js Health Dashboard"

# -----------------------------------------------------------------------------
# MODULE: Vulnerabilities (default: enabled, skip with --no-vulns)
# Order matters: dashboard must be built before nodejs_rce patches it
# -----------------------------------------------------------------------------
if [[ "$DEPLOY_VULNS" == true ]]; then
    run_module "vulnerabilities/webshell_upload.sh" "Vulnerability: Webshell Upload"
    run_module "vulnerabilities/nodejs_rce.sh"      "Vulnerability: Node.js eval() RCE"
    run_module "vulnerabilities/backdoor_bashrc.sh" "Vulnerability: Backdoor .bashrc"
else
    echo ""
    echo "[setup] Skipping vulnerabilities (--no-vulns)"
fi

# -----------------------------------------------------------------------------
# MODULE: Scenarios (narrative artifacts)
# Run after users exist
# -----------------------------------------------------------------------------
run_module "scenarios/inject_bash_histories.sh" "Scenarios: Bash History Injection"

# -----------------------------------------------------------------------------
# MODULE: Defenses
# Order: iptables → ufw → fail2ban → snort → acme_av → tripwire (always last)
# -----------------------------------------------------------------------------
run_module "defenses/iptables.sh"  "Defense: iptables"
run_module "defenses/ufw.sh"       "Defense: UFW"
run_module "defenses/fail2ban.sh"  "Defense: fail2ban"
run_module "defenses/snort.sh"     "Defense: Snort NIDS"
run_module "defenses/acme_av.sh"   "Defense: ACME AV (cron)"
run_module "defenses/tripwire.sh"  "Defense: Tripwire FIM (last — baseline init)"

# -----------------------------------------------------------------------------
# Done
# -----------------------------------------------------------------------------
echo ""
echo "========================================================"
echo "  ACME Lab setup complete."
echo ""
echo "  Target IP:       192.168.56.21"
echo "  Web:             http://192.168.56.21"
echo "  Dashboard:       http://192.168.56.21/health-check"
echo "  FTP:             ftp 192.168.56.21"
echo "  SSH:             ssh <user>@192.168.56.21"
echo ""
if [[ "$DEPLOY_VULNS" == true ]]; then
echo "  Vulnerabilities: DEPLOYED"
echo "    - Webshell upload:  /uploads/ (.htaccess PHP exec)"
echo "    - Node.js RCE:      /health-check?cmd=<payload>"
echo "    - Backdoor:         mallorymartinez .bashrc -> 10.10.10.10:4444"
else
echo "  Vulnerabilities: NOT deployed (--no-vulns)"
fi
echo ""
echo "  ⚠️  Read defenses/README.md for conflict map before exercising."
echo "========================================================"