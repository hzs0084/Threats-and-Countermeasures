# users/

Creates all ACME IT Corp system accounts on the lab VM.

---

## Files

| File | Description |
|---|---|
| `create_users.sh` | Creates all seven user accounts with appropriate groups and home directories. |

---

## Accounts Created

| Username | Groups | Notes |
|---|---|---|
| `mitchmarcus` | `sudo`, `docker` | IT admin — has elevated privileges |
| `alicebrown` | `www-data` | Web upload permissions |
| `bobbarker` | — | Standard user |
| `claireredfield` | — | Standard user |
| `evejohnson` | — | Standard user |
| `fongling` | — | Has remote access script planted by `scenarios/` |
| `mallorymartinez` | `sudo` | Admin — backdoor planted in `.bashrc` by `vulnerabilities/` |

---

## Notes

- This script only creates accounts. Bash histories and planted documents are handled by `scenarios/inject_bash_histories.sh`.
- The backdoor in `mallorymartinez`'s `.bashrc` is injected by `vulnerabilities/backdoor_bashrc.sh`, not here.
- Passwords are set to the username by default for lab convenience. Change before exposing to any network.