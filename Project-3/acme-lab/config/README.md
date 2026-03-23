# config/

Static configuration files used during lab setup. These are not executable — they are referenced by scripts in other modules.

---

## Files

| File | Description |
|---|---|
| `netplan.yaml` | Network interface configuration for the lab VM. Assigns static IP `192.168.56.21` to `enp0s8`. |
| `portal_credentials.txt` | Staff portal credentials for the ACME web dashboard. These are **not** system passwords — they are application-level credentials only. |

---

## Notes

- `netplan.yaml` must be applied manually before running `setup.sh` if your interfaces differ from the defaults. See the top-level README for prerequisites.
- `portal_credentials.txt` is referenced by the dashboard and treated as a lab artifact. Mallory Martinez (admin) is listed as the last editor — this is intentional for the scenario.