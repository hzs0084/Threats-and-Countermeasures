# services/

Installs and configures the core services that make up the ACME IT Corp lab environment.

---

## Files

| Script | Service | Port(s) | Notes |
|---|---|---|---|
| `apache.sh` | Apache2 + PHP | 80 | Enables PHP, creates uploads dir, configures reverse proxy to dashboard |
| `vsftpd.sh` | vsftpd FTP | 21, 6200 | Deploys vsftpd 2.3.4 (backdoor version) via Docker |
| `ssh.sh` | OpenSSH | 22 | Ensures SSH is enabled and running |
| `dashboard.sh` | Next.js health dashboard | 3000 | Installs Node 20, builds the app, registers systemd service |

---

## Dependency Order

```
ssh.sh        (no deps)
vsftpd.sh     (requires Docker — run after docker is installed)
apache.sh     (no deps beyond apt)
dashboard.sh  (requires Node.js 20)
```

`setup.sh` handles this order automatically.

---

## Notes

- Apache's `/var/www/html/uploads/` directory is created here but the `.htaccess` webshell trick is applied by `vulnerabilities/webshell_upload.sh`.
- The Next.js dashboard deployed by `dashboard.sh` is a **clean** version. The `eval()` RCE is injected by `vulnerabilities/nodejs_rce.sh`.
- vsftpd is intentionally the backdoored 2.3.4 version — this is the lab vulnerability, not a misconfiguration.