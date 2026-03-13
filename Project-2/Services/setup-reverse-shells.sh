#!/bin/bash
# Complete PHP Setup for Reverse Shell Lab
# This enables ALL common methods students might use

echo "=========================================="
echo "  PHP Reverse Shell Lab Setup"
echo "=========================================="
echo ""
echo "This script will configure PHP to allow ALL common reverse shell methods"
echo "WARNING: This is intentionally insecure - ONLY for isolated lab environments!"
echo ""
read -p "Continue? (y/n) " -n 1 -r
echo ""
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Aborted."
    exit 1
fi

# Detect PHP version
PHP_VERSION=$(php -r "echo PHP_MAJOR_VERSION.'.'.PHP_MINOR_VERSION;")
echo "Detected PHP version: $PHP_VERSION"

# Paths
APACHE_INI="/etc/php/$PHP_VERSION/apache2/php.ini"
CLI_INI="/etc/php/$PHP_VERSION/cli/php.ini"

echo ""
echo "=== Step 1: Enable Dangerous PHP Functions ==="
echo ""

# Backup php.ini files
echo "Backing up php.ini files..."
cp "$APACHE_INI" "${APACHE_INI}.bak"
cp "$CLI_INI" "${CLI_INI}.bak"
echo "✓ Backups created"

# Check current disabled functions
echo ""
echo "Currently disabled functions:"
grep "^disable_functions" "$APACHE_INI" | cut -d= -f2
echo ""

# Comment out disable_functions line (enable everything)
echo "Enabling all PHP functions..."
sed -i 's/^disable_functions/;disable_functions/' "$APACHE_INI"
sed -i 's/^disable_functions/;disable_functions/' "$CLI_INI"

# Verify it's commented out
if grep -q "^;disable_functions" "$APACHE_INI"; then
    echo "✓ All functions enabled in Apache PHP"
else
    echo "⚠ Warning: Could not modify Apache php.ini"
fi

if grep -q "^;disable_functions" "$CLI_INI"; then
    echo "✓ All functions enabled in CLI PHP"
else
    echo "⚠ Warning: Could not modify CLI php.ini"
fi

echo ""
echo "=== Step 2: Increase PHP Limits ==="
echo ""

# Increase execution time (reverse shells need time)
sed -i 's/^max_execution_time = .*/max_execution_time = 300/' "$APACHE_INI"
echo "✓ max_execution_time = 300"

# Increase memory limit
sed -i 's/^memory_limit = .*/memory_limit = 256M/' "$APACHE_INI"
echo "✓ memory_limit = 256M"

# Enable output buffering off (for real-time shell output)
sed -i 's/^output_buffering = .*/output_buffering = Off/' "$APACHE_INI"
echo "✓ output_buffering = Off"

echo ""
echo "=== Step 3: Install Common Shell Tools ==="
echo ""

# Install tools students might use
apt-get update -qq
echo "Installing netcat, socat, python3..."
apt-get install -y netcat-traditional socat python3 python3-pty 2>&1 | grep -E "Setting up|already"

# Make sure nc uses traditional version (supports -e flag)
update-alternatives --set nc /bin/nc.traditional 2>/dev/null
echo "✓ Netcat (traditional) installed"

echo ""
echo "=== Step 4: Configure Apache for Uploads ==="
echo ""

# Ensure uploads directory exists and is writable
mkdir -p /var/www/html/uploads
chown www-data:www-data /var/www/html/uploads
chmod 755 /var/www/html/uploads
echo "✓ Uploads directory configured"

# Check if PHP execution in uploads is already configured
if ! grep -q "/var/www/html/uploads" /etc/apache2/sites-enabled/000-default.conf; then
    echo "Adding PHP execution configuration for uploads directory..."
    
    # Add configuration before </VirtualHost>
    sed -i '/<\/VirtualHost>/i \
\
    # INTENTIONAL VULNERABILITY: Allow PHP execution in uploads\
    <Directory /var/www/html/uploads>\
        Options Indexes FollowSymLinks\
        AllowOverride None\
        Require all granted\
        php_admin_flag engine on\
        <FilesMatch "\\.php$">\
            SetHandler application/x-httpd-php\
        </FilesMatch>\
    </Directory>' /etc/apache2/sites-enabled/000-default.conf
    
    echo "✓ Apache configured to execute PHP in uploads/"
else
    echo "✓ Uploads directory already configured"
fi

echo ""
echo "=== Step 5: Restart Apache ==="
echo ""

# Test Apache configuration
echo "Testing Apache configuration..."
apache2ctl -t

if [ $? -eq 0 ]; then
    echo "✓ Apache config valid"
    systemctl restart apache2
    echo "✓ Apache restarted"
else
    echo "✗ Apache config error! Restoring backups..."
    cp "${APACHE_INI}.bak" "$APACHE_INI"
    systemctl restart apache2
    exit 1
fi

echo ""
echo "=== Step 6: Verification ==="
echo ""

# Test that functions are available
echo "Checking critical functions:"

for func in proc_open exec shell_exec system passthru popen pcntl_exec; do
    if php -r "echo function_exists('$func') ? 'YES' : 'NO';" 2>/dev/null | grep -q "YES"; then
        echo "  ✓ $func - available"
    else
        echo "  ✗ $func - not available"
    fi
done

echo ""
echo "Checking installed tools:"
which nc && echo "  ✓ nc (netcat)" || echo "  ✗ nc missing"
which socat && echo "  ✓ socat" || echo "  ✗ socat missing"  
which python3 && echo "  ✓ python3" || echo "  ✗ python3 missing"
which bash && echo "  ✓ bash" || echo "  ✗ bash missing"

echo ""
echo "Checking Apache PHP module:"
apache2ctl -M 2>/dev/null | grep -q php && echo "  ✓ PHP module loaded" || echo "  ✗ PHP module NOT loaded"

echo ""
echo "=========================================="
echo "  Setup Complete!"
echo "=========================================="
echo ""
echo "Students can now use ANY of these reverse shell methods:"
echo ""
echo "1. PHP proc_open() shells"
echo "2. PHP exec/system/shell_exec shells"
echo "3. Bash /dev/tcp reverse shells"
echo "4. Netcat reverse shells (nc -e)"
echo "5. Socat reverse shells"
echo "6. Python reverse shells"
echo "7. Perl reverse shells"
echo ""
echo "Test reverse shell:"
echo "  1. On Kali: nc -lvnp 4444"
echo "  2. Upload any PHP reverse shell to http://192.168.56.21/upload.php"
echo "  3. Visit: http://192.168.56.21/uploads/yourshell.php"
echo ""
echo "Common shells that will work:"
echo "  - PentestMonkey PHP reverse shell"
echo "  - Ivan Sincek PHP reverse shell"
echo "  - Simple exec() shells"
echo "  - /usr/share/webshells/php/* (Kali shells)"
echo ""
echo "Backup files saved:"
echo "  - ${APACHE_INI}.bak"
echo "  - ${CLI_INI}.bak"
echo ""
