#!/bin/bash

# Ensure the script is run as root
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root (use sudo)."
   exit 1
fi

echo "Updating packages and installing vsftpd..."
apt update && apt install -y vsftpd

# Define variables
FTP_ROOT="/home/ftpuser"
CONF_FILE="/etc/vsftpd.conf"

echo "Creating the FTP directory structure..."

# Created a subfolder 'uploads' for the actual writing/uploading.
mkdir -p "$FTP_ROOT/uploads"

# Set permissions
# The root needs to be readable but not writable for vsftpd to start
chown nobody:nogroup "$FTP_ROOT"
chmod a-w "$FTP_ROOT"

# Made an upload directory and assigned only ftp user permissions to write there.
chown ftp:ftp "$FTP_ROOT/uploads"
chmod 777 "$FTP_ROOT/uploads"

echo "Configuring vsftpd..."

# Backup original config
cp "$CONF_FILE" "$CONF_FILE.bak"

# Apply the specific configurations
cat <<EOF > "$CONF_FILE"
# Standard settings

listen=NO
listen_ipv6=YES
anonymous_enable=YES
local_enable=YES
write_enable=YES
anon_upload_enable=YES
anon_mkdir_write_enable=YES
no_anon_password=YES


anon_root=$FTP_ROOT
dirmessage_enable=YES
use_localtime=YES
xferlog_enable=YES
connect_from_port_20=YES

secure_chroot_dir=/var/run/vsftpd/empty
allow_writeable_chroot=YES
pasv_min_port=40000
pasv_max_port=40100

rsa_cert_file=/etc/ssl/certs/ssl-cert-snakeoil.pem
rsa_private_key_file=/etc/ssl/private/ssl-cert-snakeoil.key
ssl_enable=NO
EOF

echo "Restarting vsftpd service..."
systemctl restart vsftpd
systemctl enable vsftpd

echo "Setup complete!"
echo "Anonymous root: $FTP_ROOT"
echo "Upload folder: $FTP_ROOT/uploads"