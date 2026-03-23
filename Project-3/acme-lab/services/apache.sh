#!/bin/bash
# =============================================================================
# ACME IT Corp - Apache2 + PHP Web Server Setup
# =============================================================================
# Installs Apache2 and PHP, creates the uploads directory, and configures
# a reverse proxy to the Next.js health dashboard on port 3000.
#
# Run independently:  sudo ./services/apache.sh
# Called by:          setup.sh
#
# Ports:  80 (HTTP)
#
# NOTE: This script does NOT apply the .htaccess webshell trick.
#       That is handled by vulnerabilities/webshell_upload.sh.
# =============================================================================

set -euo pipefail

echo "[apache] Installing Apache2 and PHP..."

apt install -y apache2 php libapache2-mod-php php-cli

# -----------------------------------------------------------------------------
# Enable PHP module
# -----------------------------------------------------------------------------
PHP_VERSION=$(php -r 'echo PHP_MAJOR_VERSION.".".PHP_MINOR_VERSION;')
a2enmod "php${PHP_VERSION}"

# -----------------------------------------------------------------------------
# Enable proxy modules (needed for dashboard reverse proxy)
# -----------------------------------------------------------------------------
a2enmod proxy proxy_http

# -----------------------------------------------------------------------------
# Create uploads directory
# Permissions: www-data owns it; world-readable for the upload functionality
# NOTE: webshell_upload.sh will add .htaccess here to enable PHP execution
# -----------------------------------------------------------------------------
mkdir -p /var/www/html/uploads
chown www-data:www-data /var/www/html/uploads
chmod 755 /var/www/html/uploads

# -----------------------------------------------------------------------------
# Create a basic phpinfo page for verification
# -----------------------------------------------------------------------------
echo "<?php phpinfo(); ?>" > /var/www/html/info.php

# -----------------------------------------------------------------------------
# Configure reverse proxy to Next.js dashboard
# Proxies /health-check -> http://127.0.0.1:3000/dashboard
# -----------------------------------------------------------------------------
VHOST_CONF="/etc/apache2/sites-enabled/000-default.conf"

if ! grep -q "health-check" "$VHOST_CONF"; then
    sed -i '/<\/VirtualHost>/i \
    # ACME Internal Health Dashboard Proxy\
    ProxyPass /health-check http://127.0.0.1:3000/dashboard\
    ProxyPassReverse /health-check http://127.0.0.1:3000/dashboard' "$VHOST_CONF"
    echo "[apache] Reverse proxy configured."
else
    echo "[apache] Reverse proxy already configured, skipping."
fi

# -----------------------------------------------------------------------------
# Start and enable Apache
# -----------------------------------------------------------------------------
systemctl enable apache2
systemctl restart apache2

echo "[apache] Apache2 running on port 80."
echo "[apache] Uploads directory: /var/www/html/uploads"
echo "[apache] Verify: curl http://127.0.0.1/info.php | grep 'PHP Version'"