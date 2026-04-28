# Project 1

This project was the first of four projects in the series of red-team/blue-team engagements. 

## Services 

21 FTP
22 SSH
80 HTTP

## FTP Config

```yaml
anonymous_enable=YES
anon_upload_enable=YES
anon_mkdir_write_enable=YES
no_anon_password=YES
anon_root=/home/alice/ftp
write_enable=YES
```

A design choice was made and made anonymous login path inside alice's directory

## Users 

- Alice
- Bob
- Eve
- Mallory


## Services Scripts

- [setup_ftp.sh](../Services/ftp/setup_ftp.sh)
- [index.html](../Services/webpage/index.html) - Webpage Code

## Users Script

- [create_users.sh](../Users/create_users.sh) - Interactive user creation script

## Breadcrumbs


```bash
sudo nano /var/www/html/internal/staff.txt
```

Contents of the staff.txt

```txt
Staff Notes:

Bob:
- Uses same password everywhere
- Still hasn't changed temp credentials

Mallory:
- Handles system administration
- Granted elevated access temporarily

Alice:
- Works closely with Mallory on audits
```


```bash
sudo vim /var/www/html/backup/users.bak
```

Contents of users.bak

```txt
# Legacy migration backup (DO NOT EXPOSE)
# 2023-11-12

bob
temporary password: charlie

alice
password reset pending

mallory
access unchanged
```


```bash

sudo vim /var/www/html/robots.txt
```


```txt
User-agent: *
Disallow: /backup/
Disallow: /internal/
```

Webpage Dir Structure

```bash
/var/www/html
├── index.html
├── robots.txt
├── backup/
│   └── users.bak
├── internal/
│   └── staff.txt
├── notes/
│   └── reminder.txt
```

Made a users group and added all the users under that group

```bash
sudo chown -R alice:users /home/bob
sudo chown -R bob:users /home/bob
sudo chown -R eve:users /home/eve
sudo chown -R mallory:users /home/mallory
sudo chown -R ftpuser:users /home/ftpuser
```

Made a www-data user and assigned it it's own group and lax permissions on the website dir

```bash
sudo chown -R www-data:www-data /var/www/html
sudo chmod -R 755 /var/www/html
```

*The only thing that the documentaion is missing is the installaion of apache*