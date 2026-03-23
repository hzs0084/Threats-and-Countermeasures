# scenarios/

Plants narrative artifacts that simulate user activity. These are fabricated — they exist to give the lab a story and to give students forensic artifacts to discover and interpret.

---

## Files

| Script | What it plants |
|---|---|
| `inject_bash_histories.sh` | Fake `.bash_history` files for claire, eve, mitch, and mallory |

---

## Why This Is Separate from `users/`

Account creation (`users/create_users.sh`) and narrative injection are different operations. Keeping them separate means you can:

- Re-run `inject_bash_histories.sh` independently to reset the story state (e.g. after a student wipes a history file) without touching system accounts
- Modify the scenario (change what eve did, add a new user's history) without touching the provisioning logic

---

## Planted Artifacts Summary

| User | Artifact | Story implication |
|---|---|---|
| `claireredfield` | FTP session to 172.16.0.2, browsed Documents | Accessed internal FTP — was she exfiltrating? |
| `evejohnson` | Stopped snort, fail2ban, disabled ufw, flushed iptables | Deliberately disabled defenses — insider threat? |
| `mitchmarcus` | FTP session, browsed Docker lab directory | Aware of the lab infrastructure |
| `mallorymartinez` | (Backdoor in .bashrc — see vulnerabilities/) | Compromised admin account |