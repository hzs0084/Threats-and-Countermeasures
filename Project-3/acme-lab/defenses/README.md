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