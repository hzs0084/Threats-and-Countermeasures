## Project - 3 Storyline

- Refer to the [OSINT.txt](./OSINT.txt) for recon and osint phase of MITRE ATT&CK

- [Employee Data](./EmployeeData.txt) was found during the search for credential search through the dark web

### Company Portfolio

**ACME IT Corp**

- 6 employees

#### Initial Access Options

1) Mitch Marcus's information about using the password pattern to figure out the current password pattern

2) PHP reverse shell upload that is hidden and doesn't check for file signatures it only looks for extension check

3) React2Shell for access

#### Defensive techniques

1) Deploy Tripwire

2) Deploy Fail2ban

3) Deploy a cron job that looks for linpeas.sh and acts like a antivirus to remove it, if downloaded by anyone

4) Use Snort to detect network traffic

5) Firewall rules that respond slowly to time out nmap scans

6) Nmap scans won't be reliable as the services would be switched to different ports

7) Rabbit holes in directories so dirbuster and gobuster don't return a lot of results

8) Any user that uses root, other than Mallory, gets locked out for 15 minutes and terminates the session right away because they triggered a defense mechanism

##### Offensive techniques

1) After initial access, conduct another scan and then the host is only reachable from inside the network by gaining access to that account or machine

2) Use FTP as the deploy the version 2.3.4 to get backdoor to Mitch's FTP server that will give anonymous access but only get root when the vuln is exploited. Nothing of note to be found in the anonymous login. 

3) React2Shell POC to get root on the website

4) Mitch's account will server as intial access and that's it. All initial access will lead here

5) Bob's account will have rabbit holes

6) Claire's account will have hisotry of ftp access as a breadcrumb that there is another host that needs to be found after intitial access

7) Eve's account will have access to turn off defenses because she helps Mitch maintain FTP site so they can turn off defense evasion techniques here, to evade, masquerade, and hide their activity. 

8) Persistence mechanism by adding a backdoor to Mallory's account so every time she loggs in, a reverse shell is sent out so that the attackers can still maintain access




