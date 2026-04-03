#!/bin/bash

# Configuration
USER_EVE="evejohnson"
HOME_EVE="/home/$USER_EVE"

echo "[+] Expanding Eve Johnson's workspace with high-detail technical support content..."

# 1. Create Additional Directory Structure
mkdir -p $HOME_EVE/{Documentation,Monitoring_Logs,Personal_Folder,Network_Scans,Knowledge_Base,Ticket_History,Workstation_Images,Server_Room_Logs,Vendor_Downloads}

# 2. Knowledge Base (Standardizing the "No Microsoft" Environment)
cat << 'EOF' > $HOME_EVE/Knowledge_Base/ACME_Standard_Desktop.md
# ACME IT Corp - Linux Desktop Standards
**Authored by:** Eve Johnson (Updated 2025)

As per Mallory’s strict "No Microsoft Products" policy, all workstations 
must run an approved Linux distribution. 

### Core Applications:
- Browser: Firefox (Hardened profile)
- Productivity: LibreOffice
- Email: Thunderbird
- Security: Local Fail2ban and ClamAV

*Note: If a client (like Bob's leads) sends a .docx, use the conversion 
server. Do NOT install Microsoft fonts or viewers.*
EOF

# 3. Ticket History (Reflecting interactions with Bob and Mitch)
cat << 'EOF' > $HOME_EVE/Ticket_History/Closed_Q1_2026.txt
Ticket #882 - Bob Barker: "Laptop Fan Noise"
- Status: Closed
- Resolution: Opened chassis, cleared dust from intake. Reminded Bob not 
to use the laptop on the carpeted floor in the breakroom.

Ticket #885 - Mitch Marcus: "FTP Log Rotation"
- Status: Closed
- Resolution: Mitch was complaining about disk space on Host-02. I set 
up a cron job to compress logs older than 30 days. He said he "would 
have done it himself" but was too busy with the site migration.

Ticket #890 - Claire Redfield: "Scanner Permissions"
- Status: Closed
- Resolution: Added Claire to the 'lp' group so she can access the 
network scanner directly from her accounting workstation.
EOF

# 4. Server Room Logs (The "Physical" side of the job)
cat << 'EOF' > $HOME_EVE/Server_Room_Logs/Rack_Audit_Mar_2026.log
2026-03-01: Performed physical cable trace on Host-01. Everything labeled.
2026-03-05: Swapped out a failing fan in the secondary UPS unit.
2026-03-12: Cleaned up the "cable spaghetti" Mitch left behind the FTP rack. 
2026-03-15: Verified the paper audit log clipboard is present and signed 
by Mallory. Server room door lock confirmed functional.
EOF

# 5. Monitoring Summaries (Reflecting her "Uptime Monitoring" role)
cat << 'EOF' > $HOME_EVE/Monitoring_Logs/Weekly_Summary_Mar14.txt
ACME Internal Monitoring Report:
- Host-01 (Web): 99.98% Uptime. Two Snort alerts for directory 
  probing (automated bots). Fail2ban blocked both IPs.
- Host-02 (FTP): 100% Uptime. 
- Network Latency: Stable.
- Security Note: Reminder to Alice to check the Tripwire reports 
  for Host-01 on Monday.
EOF

# 6. Documentation (Connecting to the lab narrative)
cat << 'EOF' > $HOME_EVE/Documentation/Password_Audit_Assistance.md
# Assistance for Alice: Monthly Audits
Mallory has asked me to help Alice collect the paper password audit 
forms from Bob and Fong. 

- Bob: Usually has it ready on the 1st.
- Fong: I have to explain why we do it every time since they are 
  a contractor. Just be patient.
- Mitch: Alice handles Mitch. (Better her than me).
EOF

# 7. Personal (Adding the "Lived-in" feel)
cat << 'EOF' > $HOME_EVE/Personal_Folder/Gym_Schedule.txt
Office Gym Buddies:
- Monday: Cardio (6:00 AM)
- Wednesday: Weights with Alice (After work)
- Friday: Yoga (Claire mentioned a local class?)

Note: Don't forget to bring the extra protein bars for Mitch.
EOF

# Set Ownership and Permissions
chown -R $USER_EVE:$USER_EVE $HOME_EVE
echo "[+] Eve Johnson's environment expansion complete."
