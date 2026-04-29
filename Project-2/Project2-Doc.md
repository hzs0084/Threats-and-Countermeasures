# Project 2

Project 2 documentation. The Attack Path:

```bash
Recon
  ↓
Web Enumeration
  ↓
┌───────────────┬───────────────┬
│ Upload RCE    │ Weak Creds    │
│ (Easy)        │ (Easy/Med)    │
└───────────────┴───────────────┴
                ↓
          www-data shell
                ↓
        Local Enumeration
                ↓
┌───────────────┬───────────────┬───────────────┐
│ Writable Cron │ SUID Abuse    │ Sudo Misconfig│
│ (Easy)        │ (Medium)      │ (Medium)      │
└───────────────┴───────────────┴───────────────┘
                ↓
              Root
```
The goal was to have multiple attack vectors to get in and exploit different type of vulnerabilities to get root access. 

# YAML Settings

These settings were what I had to change to ensure that I could have internet on the project machine when installing all the packages, etc. I would then disable the NAT to ensure that no internet access was allowed. 

```yaml
network:
  version: 2
  renderer: networkd
  ethernets:
    enp0s3:            # NAT adapter
      dhcp4: true

    enp0s8:            # Host-only adapter
      dhcp4: false
      addresses:
        - 192.168.56.21/24
```

## Services

## Breadcrumns

```bash
cat >> /opt/legacy/README.txt << 'EOF'

DEVELOPER NOTES:
When testing the SUID binary, remember to use the -p flag
when spawning shells, otherwise privileges get dropped.
Test command: python3-eve -c 'import os; os.execl("/bin/sh", "sh", "-p")'
EOF
```

## WebApp

- [Webpage.tar](./WebApp/acme-fixed.tar) - Tarball with the .php code and all the files is inside this tar file

The dir structure of the webapp should look like this 


```bash
├── admin
│   ├── index.php
│   └── messages.php
├── assets
│   └── style.css
├── backups
│   └── configs
├── contact.php
├── dashboard.php
├── data
│   └── users.txt
├── index.php
├── internal
│   └── todo.txt
├── legacy
├── _lib.php
├── login.php
├── logout.php
├── robots.txt
├── upload.php
└── uploads
```

The reverse shell uploads should go to the uploads/ folder and that's where the trigger for the reverse shell occurs. 

```bash
$ cat data/users.txt 
alice:TempAccess2026:user
bob:DevPortal2026:user
eve:Onboard2026:user
mallory:AdminPortal2026:admin
```


```bash
$ cat robots.txt 
User-agent: *
Disallow: /admin/
Disallow: /notes/
Disallow: /internal/
# Disallow: /backup/   (left from old setup)
# Staff portal routes are not indexed
```

```bash
$ cat internal/todo.txt 
TODO: Fix permissions on /usr/local/bin/backup.sh before the security audit next week!
```

```bash

```

```bash

```