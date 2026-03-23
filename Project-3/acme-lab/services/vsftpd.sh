#!/bin/bash
# =============================================================================
# ACME IT Corp - vsftpd FTP Server Setup
# =============================================================================
# Deploys vsftpd 2.3.4 via Docker. This version contains the infamous smiley-
# face backdoor: sending a username ending in ":)" triggers a root shell on
# port 6200.
#
# Run independently:  sudo ./services/vsftpd.sh
# Called by:          setup.sh
#
# Ports:  21 (FTP), 6200 (backdoor shell)
#
# Requires: Docker (installed as part of full setup)
#
# ⚠️  VULNERABILITY: vsftpd 2.3.4 backdoor is intentional.
#     This is not a misconfiguration — it is the lab exercise target.
# =============================================================================

set -euo pipefail

echo "[vsftpd] Setting up vsftpd 2.3.4 (backdoor version) via Docker..."

# -----------------------------------------------------------------------------
# Verify Docker is available
# -----------------------------------------------------------------------------
if ! command -v docker &>/dev/null; then
    echo "[vsftpd] ERROR: Docker is not installed. Run setup.sh or install Docker first."
    exit 1
fi

# -----------------------------------------------------------------------------
# Create lab FTP directory
# -----------------------------------------------------------------------------
mkdir -p /opt/lab/ftp/pub
echo "[vsftpd] FTP root: /opt/lab/ftp"

# -----------------------------------------------------------------------------
# Create docker-compose file for vsftpd 2.3.4
# Uses a known vulnerable image from Docker Hub
# -----------------------------------------------------------------------------
mkdir -p /opt/lab/ftp

cat > /opt/lab/ftp/docker-compose.yml << 'EOF'
version: '3'
services:
  vsftpd:
    image: metabrainz/vsftpd:2.3.4
    container_name: vsftpd_backdoor
    ports:
      - "21:21"
      - "6200:6200"
    volumes:
      - ./pub:/var/ftp/pub
    restart: unless-stopped
EOF

# -----------------------------------------------------------------------------
# Start the container
# -----------------------------------------------------------------------------
cd /opt/lab/ftp
docker compose up -d

echo "[vsftpd] Container started."
echo "[vsftpd] FTP listening on port 21."
echo "[vsftpd] Backdoor shell available on port 6200 (trigger: username ending in ':)')."
echo "[vsftpd] Verify: docker compose -f /opt/lab/ftp/docker-compose.yml ps"