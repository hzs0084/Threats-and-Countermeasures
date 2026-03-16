# ACME Cybersecurity Lab -- Full Build Log

## System Preparation

``` bash
sudo apt update && sudo apt upgrade -y
```

``` bash
sudo apt install -y \
  apache2 \
  php libapache2-mod-php php-cli \
  vsftpd \
  fail2ban \
  tripwire \
  snort \
  ufw \
  iptables \
  net-tools \
  curl wget git \
  openssl \
  build-essential \
  libpcre3-dev libdumbnet-dev libpcap-dev zlib1g-dev \
  nodejs npm \
  cron \
  openssh-server \
  unzip \
  vim \
  auditd
```

Stop unnecessary services initially.

``` bash
sudo systemctl stop apache2
sudo systemctl stop vsftpd
sudo systemctl stop snort 2>/dev/null || true
sudo systemctl disable apache2
sudo systemctl disable vsftpd
```

Check network interfaces.

``` bash
ip a
```

------------------------------------------------------------------------

# Netplan Configuration

``` yaml
network:
  version: 2
  renderer: networkd
  ethernets:
    enp0s3:
      match:
        macaddress: 08:00:27:69:9b:d0
      set-name: enp0s3
      dhcp4: true
    enp0s8:
      match:
        macaddress: 08:00:27:6a:85:4c
      set-name: enp0s8
      dhcp4: false
      addresses:
        - 192.168.56.21/24
```

------------------------------------------------------------------------

# Tripwire Installation

``` bash
sudo apt install -y tripwire
```

Configure keys.

``` bash
sudo bash -c 'echo "tripwire tripwire/use-localkey boolean true" | debconf-set-selections'
sudo bash -c 'echo "tripwire tripwire/use-sitekey boolean true" | debconf-set-selections'
```

Set passphrases.

``` bash
SITE_PASS="ACMEsite2024!"
LOCAL_PASS="ACMElocal2024!"
```

Generate keys.

``` bash
sudo twadmin --generate-keys --site-keyfile /etc/tripwire/site.key --site-passphrase "$SITE_PASS"
sudo twadmin --generate-keys --local-keyfile /etc/tripwire/$(hostname)-local.key --local-passphrase "$LOCAL_PASS"
```

Create config and policy.

``` bash
sudo twadmin --create-cfgfile \
  --site-keyfile /etc/tripwire/site.key \
  --cfgfile /etc/tripwire/tw.cfg \
  --site-passphrase "$SITE_PASS" \
  /etc/tripwire/twcfg.txt
```

``` bash
sudo twadmin --create-polfile \
  --site-keyfile /etc/tripwire/site.key \
  --site-passphrase "$SITE_PASS" \
  /etc/tripwire/twpol.txt
```

Initialize database.

``` bash
sudo tripwire --init --local-passphrase "$LOCAL_PASS"
```

------------------------------------------------------------------------

# Apache + PHP Setup

Enable Apache.

``` bash
sudo systemctl enable apache2
sudo systemctl start apache2
```

Enable PHP module.

``` bash
sudo a2enmod php$(php -r 'echo PHP_MAJOR_VERSION.".".PHP_MINOR_VERSION;')
sudo systemctl restart apache2
```

Verify service.

``` bash
curl -s http://127.0.0.1 | head -5
```

Create phpinfo test page.

``` bash
echo "<?php phpinfo(); ?>" | sudo tee /var/www/html/info.php
curl -s http://127.0.0.1/info.php | grep "PHP Version" | head -3
```

------------------------------------------------------------------------

# Docker Installation

``` bash
sudo apt install -y ca-certificates curl gnupg lsb-release
```

``` bash
sudo install -m 0755 -d /etc/apt/keyrings
```

``` bash
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | \
  sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
```

``` bash
sudo chmod a+r /etc/apt/keyrings/docker.gpg
```

``` bash
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
  https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
```

``` bash
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
```

``` bash
sudo systemctl enable docker
sudo systemctl start docker
```

Verify Docker.

``` bash
docker --version
docker compose version
```

------------------------------------------------------------------------

# FTP Lab Environment

``` bash
sudo mkdir -p /opt/lab/ftp
cd /opt/lab/ftp
sudo mkdir -p /opt/lab/ftp/pub
```

------------------------------------------------------------------------

# Users File

``` text
# ACME IT Corp - Staff Portal Credentials
# Format: username:password:role
# Last updated: Mallory Martinez
#
# NOTE: These are portal-only credentials, separate from system accounts.
# Do not store system passwords here.
mitchmarcus:ITAdmin2026:admin
alicebrown:AlicePortal2026:user    # Only Alice can upload files
bobbarker:BobPortal2026:user
claireredfield:ClairePortal2026:user
evejohnson:EvePortal2026:user
fongling:FongPortal2026:user
mallorymartinez:MalloryPortal2026:admin
```

------------------------------------------------------------------------

# NodeJS Installation

``` bash
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt-get install -y nodejs
node -v
```

------------------------------------------------------------------------

# Next.js Health Dashboard

``` bash
sudo mkdir -p /opt/acme-next-dashboard
cd /opt/acme-next-dashboard

sudo npm init -y
sudo npm install next react react-dom
```

Create package.json.

``` json
{
  "name": "acme-next-dashboard",
  "version": "0.1.0",
  "private": true,
  "scripts": {
    "dev": "next dev",
    "build": "next build",
    "start": "next start",
    "lint": "next lint"
  },
  "dependencies": {
    "next": "16.1.6",
    "react": "latest",
    "react-dom": "latest"
  }
}
```

Build the application.

``` bash
sudo npm install
sudo npm run build
```

------------------------------------------------------------------------

# Systemd Service

``` bash
sudo tee /etc/systemd/system/acme-health.service > /dev/null << 'EOF'
[Unit]
Description=ACME Health Dashboard (Next.js)
After=network.target

[Service]
Type=simple
User=root
WorkingDirectory=/opt/acme-next-dashboard
ExecStart=/usr/bin/npm run start
Restart=always

[Install]
WantedBy=multi-user.target
EOF
```

Enable the service.

``` bash
sudo systemctl daemon-reload
sudo systemctl enable acme-health
sudo systemctl start acme-health
```

------------------------------------------------------------------------

# Apache Reverse Proxy

``` bash
sudo a2enmod proxy proxy_http
```

``` bash
sudo sed -i '/<\/VirtualHost>/i \
    # ACME Internal Health Dashboard Proxy \
    ProxyPass /health-check http://127.0.0.1:3000/dashboard \
    ProxyPassReverse /health-check http://127.0.0.1:3000/dashboard' /etc/apache2/sites-enabled/000-default.conf
```

``` bash
sudo systemctl restart apache2
```

------------------------------------------------------------------------

# Fong Ling Remote Tool Setup

``` bash
sudo mkdir -p /home/fongling/Scripts
sudo nano /home/fongling/Scripts/RemoteAccess_v1.py
sudo chmod +x /home/fongling/Scripts/RemoteAccess_v1.py
```

Create documentation.

``` bash
sudo mkdir -p /home/fongling/Documents
```

``` bash
sudo tee /home/fongling/Documents/WFH_Instructions.txt > /dev/null << 'EOF'
Fong,
If you need to work from home this weekend, use the maintenance
script in ~/Scripts. Make sure you have your listener running first.
Don't let Mallory see this—she's still paranoid about the 2010
breach and hates remote shells.
EOF
```

Set permissions.

``` bash
sudo chown -R fongling:fongling /home/fongling
```

------------------------------------------------------------------------

# Dashboard Update

``` bash
sudo tee /opt/acme-next-dashboard/pages/dashboard.js > /dev/null << 'EOF'
[React Next.js dashboard code]
EOF
```

``` bash
cd /opt/acme-next-dashboard && sudo npm run build
sudo systemctl restart acme-health
```

------------------------------------------------------------------------

# End of Lab Build Log
