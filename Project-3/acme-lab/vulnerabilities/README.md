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