# ACME Cybersecurity Lab
 
A modular, intentionally vulnerable Linux lab environment for practicing offensive and defensive security techniques.
 
---
 
## What This Lab Is
 
This lab simulates the internal infrastructure of a fictional company, **ACME IT Corp**. It includes:
 
- A web server with an exploitable file upload and a Node.js RCE
- An FTP server with a known backdoor
- A staff portal with hardcoded credentials
- Planted user artifacts (bash histories, documents) to simulate insider activity
- A suite of defenses (Snort, iptables, fail2ban, Tripwire, a custom AV script) that students can observe, bypass, or analyze
 
---
 
## Prerequisites
 
- Ubuntu 22.04 LTS (tested on VirtualBox with two NICs)
- Two network interfaces:
  - `enp0s3` — NAT / internet access (DHCP)
  - `enp0s8` — Host-only adapter, static IP `192.168.56.21/24`
- Run all scripts as a user with `sudo` privileges
- Internet access required during setup (apt installs)
 
---
 
## Quick Start
 
```bash
git clone <repo-url>
cd Project-3/acme-lab
chmod +x setup.sh
sudo ./setup.sh
```
 
This deploys the full lab including vulnerabilities. See [Sequencing Warnings](#sequencing-warnings) before running individual modules.
 
---
 
## Directory Structure
 
```
acme-lab/
├── setup.sh                        # Master orchestrator
├── README.md                       # This file
├── config/                         # Static config files (netplan, credentials)
├── users/                          # System account creation
├── services/                       # Apache, vsftpd, SSH, Next.js dashboard
├── vulnerabilities/                # Intentional weaknesses
├── scenarios/                      # Narrative artifacts (bash histories, docs)
└── defenses/                       # Snort, iptables, UFW, fail2ban, Tripwire, acme-av
```
 
---
 
## Sequencing Warnings
 
Some modules actively conflict with each other. **If running modules individually**, read this section carefully.
 
| Conflict | Details |
|---|---|
| `defenses/acme_av.sh` vs exploitation tools | The AV cron job runs every minute and deletes linpeas, enum4linux, and ~20 other tools. Deploy and run exploitation exercises **before** enabling acme-av, or disable the cron first. |
| `defenses/iptables.sh` + `ufw.sh` vs reverse shells | Port 4444 (Mallory's backdoor) and general outbound reverse shells are blocked by the firewall rules. If testing the backdoor, either add a temporary allow rule or run `vulnerabilities/backdoor_bashrc.sh` **after** confirming your listener can receive. |
| `defenses/snort.sh` vs webshell | Snort rule `sid:1000011` fires on `cmd=` in HTTP traffic. This is **intentional** — the detection exercise depends on it. But if you want clean exploitation without alerts first, run the webshell exercise before starting Snort. |
 
See also: `vulnerabilities/README.md` and `defenses/README.md` for per-module conflict notes.
 
---
 
## Lab Users
 
| Username | Role | Notes |
|---|---|---|
| `mitchmarcus` | IT Admin | Has Docker access, FTP history |
| `alicebrown` | User | Only user with upload permissions |
| `bobbarker` | User | Standard account |
| `claireredfield` | User | FTP activity in bash history |
| `evejohnson` | User | Disabled defenses in bash history |
| `fongling` | User | Has remote access script in `~/Scripts` |
| `mallorymartinez` | Admin | Backdoor planted in `.bashrc` |
 
Portal credentials are in `config/portal_credentials.txt`.
 
---
 
## Teardown
 
There is no automated teardown script. To reset the lab, snapshot your VM before running `setup.sh` and restore from snapshot.

# vulnerabilities/

Injects the intentional weaknesses into the ACME IT Corp lab environment.

Each script in this directory is idempotent — safe to re-run if you need to reset a specific vulnerability without rebuilding the whole lab.

---

## Files

| Script | Vulnerability | Depends On |
|---|---|---|
| `webshell_upload.sh` | Apache `.htaccess` trick — executes PHP inside image/text uploads | `services/apache.sh` |
| `nodejs_rce.sh` | Next.js `eval()` RCE via `?cmd=` parameter + Fong's exploit script | `services/dashboard.sh`, `users/create_users.sh` |
| `backdoor_bashrc.sh` | Reverse shell injected into `mallorymartinez`'s `.bashrc` | `users/create_users.sh` |

---

## Conflict Map

These vulnerabilities interact with defenses in ways that affect lab sequencing.

### webshell_upload.sh
- **Conflicts with:** `defenses/snort.sh` (sid:1000011 — fires on `cmd=` in HTTP)
- **Impact:** Snort will alert every time the webshell is triggered via `?cmd=`. This is intentional for the detection exercise. If you want clean exploitation first, run the webshell exercise before starting Snort.
- **Also conflicts with:** `defenses/iptables.sh` — the `.htaccess` upload path relies on Apache being reachable on port 80. Confirm UFW/iptables allow port 80 (they do by default in this lab).

### nodejs_rce.sh
- **Conflicts with:** `defenses/snort.sh` (sid:1000012 — detects `/bin/sh` in outbound traffic)
- **Impact:** Reverse shell payloads sent through the RCE will trigger Snort. Intentional.
- **Also conflicts with:** `defenses/iptables.sh` + `defenses/ufw.sh` — outbound connections on arbitrary ports (e.g. 4444) are not explicitly allowed. You may need to temporarily add an allow rule when testing the shell.

### backdoor_bashrc.sh
- **Conflicts with:** `defenses/iptables.sh` + `defenses/ufw.sh`
- **Impact:** The backdoor connects out to `10.10.10.10:4444`. This outbound connection will be blocked unless you add an explicit allow rule or disable the outbound firewall restrictions.
- **Trigger:** The backdoor fires every time `mallorymartinez` opens a new shell session. To test it, `su - mallorymartinez` or SSH in as her.
- **Detection:** Snort sid:1000012 (`/bin/sh` outbound) will fire if the connection succeeds.

---

## Reset Instructions

To reset a specific vulnerability without rebuilding:

```bash
# Reset webshell
sudo rm /var/www/html/uploads/.htaccess
sudo rm -f /etc/apache2/conf-available/uploads.conf
sudo a2disconf uploads 2>/dev/null
sudo systemctl restart apache2
sudo ./vulnerabilities/webshell_upload.sh

# Reset nodejs RCE
sudo ./services/dashboard.sh          # Redeploys clean dashboard
sudo ./vulnerabilities/nodejs_rce.sh  # Re-injects eval()

# Reset backdoor
sudo sed -i '/bash -i >& \/dev\/tcp/d' /home/mallorymartinez/.bashrc
sudo ./vulnerabilities/backdoor_bashrc.sh
```

# defenses/

Installs and configures the defensive controls for the ACME IT Corp lab. Each script is standalone — run individually or via `setup.sh`.

---

## Files

| Script | Defense | Notes |
|---|---|---|
| `iptables.sh` | Firewall rules, rate limiting, scan drops | Run before UFW; persistent via netfilter-persistent |
| `ufw.sh` | UFW allow/deny rules | Layered on top of iptables |
| `snort.sh` | Snort NIDS with custom ACME ruleset | Monitors `enp0s8`; alerts logged to `/var/log/snort/` |
| `fail2ban.sh` | SSH brute-force protection | Bans IPs after repeated auth failures |
| `tripwire.sh` | File integrity monitoring | Baseline DB initialized at install time |
| `acme_av.sh` | Custom cron-based tool scanner/remover | Runs every minute; removes post-exploitation tools |

---

## Conflict Map

These defenses interact with vulnerabilities and exercises in ways that affect sequencing.

### acme_av.sh
- **Conflicts with:** Any exploitation exercise requiring linpeas, enum4linux, or similar tools
- **Impact:** The cron job runs every 60 seconds and deletes ~20 named post-exploitation tools from the entire filesystem (excluding `/opt/lab`). If you drop a tool to the target during an exercise, it will be removed within a minute.
- **Mitigation:** Either run exploitation exercises before enabling acme-av, disable the cron temporarily (`sudo crontab -r`), or place your tools under `/opt/lab/` (excluded from scanning).

### iptables.sh + ufw.sh
- **Conflicts with:** `vulnerabilities/backdoor_bashrc.sh` (port 4444 outbound)
- **Conflicts with:** `vulnerabilities/nodejs_rce.sh` (arbitrary outbound reverse shell)
- **Impact:** The firewall defaults allow outgoing traffic broadly, but the iptables SYN rate limiting and UFW defaults may interfere with some reverse shell setups depending on timing.
- **Mitigation:** If your reverse shell isn't connecting, check `sudo ufw status` and `sudo iptables -L` — add a temporary explicit allow for your listener port.

### snort.sh
- **Conflicts with:** `vulnerabilities/webshell_upload.sh` — sid:1000011 fires on `?cmd=` in HTTP
- **Conflicts with:** `vulnerabilities/nodejs_rce.sh` — sid:1000012 fires on `/bin/sh` outbound
- **Conflicts with:** vsftpd backdoor — sid:1000007/1000008 fire on `:)` username and port 6200
- **Impact:** All of the above are **intentional** — the detection exercises depend on these alerts. If you want clean exploitation without Snort noise, stop Snort first (`sudo systemctl stop snort`), run your exercise, then restart it to observe the alerts afterward.
- **Alert log:** `/var/log/snort/snort.alert.fast`

### tripwire.sh
- **Conflicts with:** Any script that modifies system files after baseline initialization
- **Impact:** Tripwire will report changes to files in its policy (default `/etc`, `/bin`, `/usr`, etc.) after any of the setup scripts run. If you initialize Tripwire before running other modules, you will see many false-positive alerts.
- **Mitigation:** Run `tripwire.sh` last, after the rest of the lab is fully configured, to get a clean baseline.

---

## Recommended Defense Deployment Order

If running defenses individually (not via `setup.sh`):

```
1. iptables.sh
2. ufw.sh
3. fail2ban.sh
4. snort.sh
5. acme_av.sh
6. tripwire.sh   ← always last
```